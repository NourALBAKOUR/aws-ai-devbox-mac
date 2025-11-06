"""
SageMaker Inference Example
Demonstrates how to deploy models and run inference using Amazon SageMaker
"""

import boto3
import sagemaker
from sagemaker import get_execution_role
from sagemaker.predictor import Predictor
from sagemaker.serializers import CSVSerializer
from sagemaker.deserializers import JSONDeserializer
import json
import numpy as np


class SageMakerInference:
    """Client for running inference with SageMaker"""
    
    def __init__(self, role_arn: str = None, region_name: str = "us-east-1"):
        """
        Initialize SageMaker inference client
        
        Args:
            role_arn: IAM role ARN for SageMaker
            region_name: AWS region name
        """
        self.session = sagemaker.Session(boto_session=boto3.Session(region_name=region_name))
        
        if role_arn:
            self.role = role_arn
        else:
            try:
                self.role = get_execution_role()
            except:
                print("Warning: Could not get execution role.")
                self.role = None
        
        self.runtime_client = boto3.client("sagemaker-runtime", region_name=region_name)
    
    def deploy_model(
        self,
        model_data: str,
        image_uri: str,
        endpoint_name: str,
        instance_type: str = "ml.t2.medium",
        instance_count: int = 1
    ) -> str:
        """
        Deploy a model to a SageMaker endpoint
        
        Args:
            model_data: S3 URI of model artifacts
            image_uri: Container image URI
            endpoint_name: Name for the endpoint
            instance_type: Instance type for hosting
            instance_count: Number of instances
            
        Returns:
            Endpoint name
        """
        from sagemaker.model import Model
        
        model = Model(
            model_data=model_data,
            image_uri=image_uri,
            role=self.role,
            sagemaker_session=self.session
        )
        
        print(f"Deploying model to endpoint: {endpoint_name}")
        predictor = model.deploy(
            initial_instance_count=instance_count,
            instance_type=instance_type,
            endpoint_name=endpoint_name
        )
        
        print(f"Model deployed to endpoint: {endpoint_name}")
        return endpoint_name
    
    def invoke_endpoint(
        self,
        endpoint_name: str,
        data: np.ndarray,
        content_type: str = "text/csv"
    ) -> dict:
        """
        Invoke a SageMaker endpoint
        
        Args:
            endpoint_name: Name of the endpoint
            data: Input data for inference
            content_type: Content type of input data
            
        Returns:
            Prediction results
        """
        # Convert numpy array to CSV string
        if isinstance(data, np.ndarray):
            if len(data.shape) == 1:
                data = data.reshape(1, -1)
            payload = "\n".join([",".join(map(str, row)) for row in data])
        else:
            payload = data
        
        response = self.runtime_client.invoke_endpoint(
            EndpointName=endpoint_name,
            ContentType=content_type,
            Body=payload
        )
        
        result = json.loads(response["Body"].read().decode())
        return result
    
    def batch_transform(
        self,
        model_name: str,
        input_data_s3_uri: str,
        output_data_s3_uri: str,
        instance_type: str = "ml.m5.large",
        instance_count: int = 1
    ):
        """
        Run batch transform job for offline inference
        
        Args:
            model_name: Name of the model
            input_data_s3_uri: S3 URI of input data
            output_data_s3_uri: S3 URI for output
            instance_type: Instance type for transform
            instance_count: Number of instances
            
        Returns:
            Transformer object
        """
        from sagemaker.transformer import Transformer
        from sagemaker.model import Model
        
        # Retrieve model
        sm_client = boto3.client("sagemaker")
        model_desc = sm_client.describe_model(ModelName=model_name)
        
        model = Model(
            model_data=model_desc["PrimaryContainer"]["ModelDataUrl"],
            image_uri=model_desc["PrimaryContainer"]["Image"],
            role=self.role,
            sagemaker_session=self.session
        )
        
        transformer = Transformer(
            model_name=model_name,
            instance_count=instance_count,
            instance_type=instance_type,
            output_path=output_data_s3_uri,
            sagemaker_session=self.session
        )
        
        print("Starting batch transform job...")
        transformer.transform(
            data=input_data_s3_uri,
            content_type="text/csv",
            split_type="Line"
        )
        
        print("Waiting for batch transform to complete...")
        transformer.wait()
        print("Batch transform completed!")
        
        return transformer
    
    def delete_endpoint(self, endpoint_name: str):
        """
        Delete a SageMaker endpoint
        
        Args:
            endpoint_name: Name of the endpoint to delete
        """
        sm_client = boto3.client("sagemaker")
        
        print(f"Deleting endpoint: {endpoint_name}")
        sm_client.delete_endpoint(EndpointName=endpoint_name)
        
        # Also delete endpoint configuration
        try:
            endpoint_config = sm_client.describe_endpoint(
                EndpointName=endpoint_name
            )["EndpointConfigName"]
            sm_client.delete_endpoint_config(EndpointConfigName=endpoint_config)
            print(f"Deleted endpoint configuration: {endpoint_config}")
        except:
            pass
        
        print(f"Endpoint deleted: {endpoint_name}")
    
    def list_endpoints(self) -> list:
        """
        List all SageMaker endpoints
        
        Returns:
            List of endpoint names
        """
        sm_client = boto3.client("sagemaker")
        response = sm_client.list_endpoints()
        endpoints = [ep["EndpointName"] for ep in response["Endpoints"]]
        return endpoints


def main():
    """Main function demonstrating SageMaker inference"""
    print("SageMaker Inference Examples\n" + "=" * 50)
    
    # Initialize inference client
    inference_client = SageMakerInference()
    
    # List existing endpoints
    print("\n1. Listing SageMaker endpoints:")
    try:
        endpoints = inference_client.list_endpoints()
        if endpoints:
            for endpoint in endpoints:
                print(f"  - {endpoint}")
        else:
            print("  No endpoints found")
    except Exception as e:
        print(f"  Error listing endpoints: {e}")
    
    # Example: Invoke endpoint
    print("\n2. Invoking endpoint (example):")
    print("  To invoke an endpoint, you need:")
    print("  - A deployed endpoint")
    print("  - Sample input data")
    print("\n  Example code:")
    print("  ```python")
    print("  data = np.array([[1.0, 2.0, 3.0, 4.0, 5.0]])")
    print("  result = inference_client.invoke_endpoint('my-endpoint', data)")
    print("  print(result)")
    print("  ```")
    
    # Example: Batch transform
    print("\n3. Batch Transform (example):")
    print("  For offline batch inference on large datasets:")
    print("  ```python")
    print("  transformer = inference_client.batch_transform(")
    print("      model_name='my-model',")
    print("      input_data_s3_uri='s3://bucket/input/',")
    print("      output_data_s3_uri='s3://bucket/output/'")
    print("  )")
    print("  ```")


if __name__ == "__main__":
    main()

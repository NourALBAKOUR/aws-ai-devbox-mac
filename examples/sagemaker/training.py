"""
SageMaker Training Example
Demonstrates how to train a model using Amazon SageMaker
"""

import boto3
import sagemaker
from sagemaker import get_execution_role
from sagemaker.sklearn import SKLearn
from sagemaker.estimator import Estimator
import pandas as pd
import numpy as np
from sklearn.datasets import make_classification
from sklearn.model_selection import train_test_split
import os


class SageMakerTrainer:
    """Client for training models with SageMaker"""
    
    def __init__(self, role_arn: str = None, region_name: str = "us-east-1"):
        """
        Initialize SageMaker trainer
        
        Args:
            role_arn: IAM role ARN for SageMaker (if not provided, will try to get execution role)
            region_name: AWS region name
        """
        self.session = sagemaker.Session(boto_session=boto3.Session(region_name=region_name))
        
        if role_arn:
            self.role = role_arn
        else:
            try:
                self.role = get_execution_role()
            except:
                print("Warning: Could not get execution role. Please provide role_arn parameter.")
                self.role = None
        
        self.bucket = self.session.default_bucket()
        self.prefix = "sagemaker-training"
    
    def prepare_sample_data(self, output_dir: str = "/tmp/data"):
        """
        Prepare sample classification dataset
        
        Args:
            output_dir: Directory to save data
            
        Returns:
            Paths to train and test data
        """
        os.makedirs(output_dir, exist_ok=True)
        
        # Generate sample data
        X, y = make_classification(
            n_samples=1000,
            n_features=20,
            n_informative=15,
            n_redundant=5,
            random_state=42
        )
        
        # Split data
        X_train, X_test, y_train, y_test = train_test_split(
            X, y, test_size=0.2, random_state=42
        )
        
        # Save as CSV
        train_data = pd.DataFrame(X_train)
        train_data["target"] = y_train
        train_path = os.path.join(output_dir, "train.csv")
        train_data.to_csv(train_path, index=False, header=False)
        
        test_data = pd.DataFrame(X_test)
        test_data["target"] = y_test
        test_path = os.path.join(output_dir, "test.csv")
        test_data.to_csv(test_path, index=False, header=False)
        
        print(f"Training data saved to: {train_path}")
        print(f"Test data saved to: {test_path}")
        
        return train_path, test_path
    
    def upload_data_to_s3(self, local_path: str, s3_prefix: str) -> str:
        """
        Upload data to S3
        
        Args:
            local_path: Local file path
            s3_prefix: S3 prefix
            
        Returns:
            S3 URI
        """
        s3_uri = self.session.upload_data(
            path=local_path,
            bucket=self.bucket,
            key_prefix=f"{self.prefix}/{s3_prefix}"
        )
        print(f"Data uploaded to: {s3_uri}")
        return s3_uri
    
    def train_sklearn_model(
        self,
        train_data_s3_uri: str,
        script_path: str = "train.py",
        instance_type: str = "ml.m5.large"
    ):
        """
        Train a scikit-learn model on SageMaker
        
        Args:
            train_data_s3_uri: S3 URI of training data
            script_path: Path to training script
            instance_type: SageMaker instance type
            
        Returns:
            Trained estimator
        """
        sklearn_estimator = SKLearn(
            entry_point=script_path,
            role=self.role,
            instance_count=1,
            instance_type=instance_type,
            framework_version="1.2-1",
            py_version="py3",
            sagemaker_session=self.session
        )
        
        print("Starting training job...")
        sklearn_estimator.fit({"train": train_data_s3_uri})
        print("Training completed!")
        
        return sklearn_estimator
    
    def train_custom_model(
        self,
        image_uri: str,
        train_data_s3_uri: str,
        instance_type: str = "ml.m5.large",
        hyperparameters: dict = None
    ):
        """
        Train a custom model using Docker container
        
        Args:
            image_uri: ECR image URI
            train_data_s3_uri: S3 URI of training data
            instance_type: SageMaker instance type
            hyperparameters: Hyperparameters for training
            
        Returns:
            Trained estimator
        """
        estimator = Estimator(
            image_uri=image_uri,
            role=self.role,
            instance_count=1,
            instance_type=instance_type,
            sagemaker_session=self.session,
            hyperparameters=hyperparameters or {}
        )
        
        print("Starting training job with custom container...")
        estimator.fit({"train": train_data_s3_uri})
        print("Training completed!")
        
        return estimator


def create_training_script(output_path: str = "/tmp/train.py"):
    """Create a sample training script"""
    script_content = """
import argparse
import os
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
import joblib


def train(args):
    # Load data
    train_data = pd.read_csv(os.path.join(args.train, "train.csv"), header=None)
    X_train = train_data.iloc[:, :-1]
    y_train = train_data.iloc[:, -1]
    
    # Train model
    model = RandomForestClassifier(
        n_estimators=args.n_estimators,
        max_depth=args.max_depth,
        random_state=42
    )
    model.fit(X_train, y_train)
    
    # Save model
    joblib.dump(model, os.path.join(args.model_dir, "model.joblib"))
    
    # Print training accuracy
    train_pred = model.predict(X_train)
    train_accuracy = accuracy_score(y_train, train_pred)
    print(f"Training Accuracy: {train_accuracy:.4f}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--n_estimators", type=int, default=100)
    parser.add_argument("--max_depth", type=int, default=10)
    parser.add_argument("--model_dir", type=str, default=os.environ.get("SM_MODEL_DIR"))
    parser.add_argument("--train", type=str, default=os.environ.get("SM_CHANNEL_TRAIN"))
    
    args = parser.parse_args()
    train(args)
"""
    
    with open(output_path, "w") as f:
        f.write(script_content)
    
    print(f"Training script created: {output_path}")
    return output_path


def main():
    """Main function demonstrating SageMaker training"""
    print("SageMaker Training Examples\n" + "=" * 50)
    
    # Initialize trainer
    # Note: You need to set up IAM role for SageMaker
    print("\nNote: This example requires a SageMaker execution role.")
    print("Set up your role ARN before running training jobs.\n")
    
    try:
        trainer = SageMakerTrainer()
        
        # Prepare sample data
        print("\n1. Preparing sample data...")
        train_path, test_path = trainer.prepare_sample_data()
        
        # Upload to S3
        print("\n2. Uploading data to S3...")
        train_s3_uri = trainer.upload_data_to_s3(train_path, "train")
        
        # Create training script
        print("\n3. Creating training script...")
        script_path = create_training_script()
        
        print("\n4. Ready to train!")
        print(f"   - Training data: {train_s3_uri}")
        print(f"   - Training script: {script_path}")
        print(f"   - Bucket: {trainer.bucket}")
        
        # Uncomment to actually run training:
        # estimator = trainer.train_sklearn_model(train_s3_uri, script_path)
        
    except Exception as e:
        print(f"Error: {e}")
        print("\nMake sure you have AWS credentials configured and SageMaker role set up.")


if __name__ == "__main__":
    main()

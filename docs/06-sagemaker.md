# 06 - Amazon SageMaker for ML Workflows

## Overview

Amazon SageMaker provides:
- **Training** - Managed training jobs with auto-scaling
- **Deployment** - Real-time and batch endpoints
- **Notebooks** - Jupyter notebooks in the cloud
- **Experiments** - Track ML experiments
- **Pipelines** - ML workflow orchestration

## SageMaker SDK Setup

Already included in Poetry environment:

```bash
cd ai/
poetry add sagemaker
poetry install
```

## Training Jobs (Script Mode)

### Prepare Training Script

`ai/src/sagemaker/train_script.py`:

```python
import argparse
import joblib
from sklearn.ensemble import RandomForestClassifier

def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--n-estimators", type=int, default=100)
    parser.add_argument("--model-dir", type=str, default="/opt/ml/model")
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()
    # Training code here
    model = RandomForestClassifier(n_estimators=args.n_estimators)
    # ... train model ...
    joblib.dump(model, f"{args.model_dir}/model.joblib")
```

### Launch Training Job

```python
import sagemaker
from sagemaker.sklearn import SKLearn

session = sagemaker.Session()
role = "arn:aws:iam::ACCOUNT:role/SageMakerExecutionRole"

estimator = SKLearn(
    entry_point="train_script.py",
    source_dir="ai/src/sagemaker/",
    role=role,
    instance_type="ml.m5.large",
    instance_count=1,
    framework_version="1.2-1",
    py_version="py3",
    hyperparameters={
        "n-estimators": 100,
        "max-depth": 10
    }
)

# Upload data to S3
train_input = session.upload_data("data/train.csv", key_prefix="training/data")

# Start training
estimator.fit({"train": train_input})
```

### Monitor Training

```bash
# View logs in real-time
# Logs appear in CloudWatch and SageMaker console
```

### Training Job Outputs

- **Model artifacts:** S3 bucket (specified in estimator)
- **Logs:** CloudWatch Logs
- **Metrics:** CloudWatch Metrics

## Deploying Models

### Deploy to Real-Time Endpoint

```python
predictor = estimator.deploy(
    initial_instance_count=1,
    instance_type="ml.t2.medium",
    endpoint_name="my-model-endpoint"
)
```

### Make Predictions

```python
import numpy as np

sample = np.array([[5.1, 3.5, 1.4, 0.2]])
prediction = predictor.predict(sample)
print(prediction)
```

### Update Endpoint

```python
# Deploy new model version
new_estimator.deploy(
    initial_instance_count=1,
    instance_type="ml.t2.medium",
    endpoint_name="my-model-endpoint",
    update_endpoint=True
)
```

### Delete Endpoint

```python
predictor.delete_endpoint()
# Or keep endpoint config for redeployment:
predictor.delete_endpoint(delete_endpoint_config=False)
```

## Custom Inference Containers

### Build Docker Image

```bash
cd docker/
make build
```

### Push to ECR

```bash
make ecr-login
make ecr-create
make push
```

### Deploy Custom Container

```python
from sagemaker.model import Model

model = Model(
    image_uri="ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/sagemaker-inference:latest",
    model_data="s3://bucket/model.tar.gz",
    role=role
)

predictor = model.deploy(
    initial_instance_count=1,
    instance_type="ml.m5.large"
)
```

## Batch Transform

For large-scale batch inference:

```python
transformer = estimator.transformer(
    instance_count=1,
    instance_type="ml.m5.large",
    output_path="s3://bucket/output"
)

transformer.transform(
    data="s3://bucket/input/data.csv",
    content_type="text/csv"
)

transformer.wait()
```

## SageMaker Notebooks

### Create Notebook Instance

```bash
aws sagemaker create-notebook-instance \
  --notebook-instance-name my-notebook \
  --instance-type ml.t3.medium \
  --role-arn arn:aws:iam::ACCOUNT:role/SageMakerExecutionRole
```

### Start/Stop Notebook

```bash
aws sagemaker start-notebook-instance --notebook-instance-name my-notebook
aws sagemaker stop-notebook-instance --notebook-instance-name my-notebook
```

### Access Notebook

AWS Console → SageMaker → Notebook instances → Open JupyterLab

## SageMaker Studio (Recommended)

Integrated ML development environment:

```bash
aws sagemaker create-domain \
  --domain-name my-studio \
  --auth-mode IAM \
  --default-user-settings '{
    "ExecutionRole": "arn:aws:iam::ACCOUNT:role/SageMakerExecutionRole"
  }'
```

## Experiment Tracking

```python
from sagemaker.experiments import Run

with Run(experiment_name="my-experiment", run_name="run-001") as run:
    run.log_parameter("n_estimators", 100)
    run.log_parameter("max_depth", 10)
    
    # Train model
    estimator.fit(train_input)
    
    run.log_metric("accuracy", 0.95)
```

## Model Registry

### Register Model

```python
from sagemaker.model import Model

model = Model(
    image_uri=image_uri,
    model_data=model_artifacts,
    role=role
)

model_package = model.register(
    model_package_group_name="my-models",
    content_types=["application/json"],
    response_types=["application/json"],
    inference_instances=["ml.m5.large"],
    transform_instances=["ml.m5.large"]
)
```

### Deploy from Registry

```python
model = Model(
    model_package_arn="arn:aws:sagemaker:...:model-package/...",
    role=role
)

predictor = model.deploy(
    initial_instance_count=1,
    instance_type="ml.m5.large"
)
```

## Autoscaling

```python
import boto3

client = boto3.client("application-autoscaling")

# Register endpoint as scalable target
client.register_scalable_target(
    ServiceNamespace="sagemaker",
    ResourceId=f"endpoint/{endpoint_name}/variant/AllTraffic",
    ScalableDimension="sagemaker:variant:DesiredInstanceCount",
    MinCapacity=1,
    MaxCapacity=10
)

# Configure scaling policy
client.put_scaling_policy(
    PolicyName="target-tracking-policy",
    ServiceNamespace="sagemaker",
    ResourceId=f"endpoint/{endpoint_name}/variant/AllTraffic",
    ScalableDimension="sagemaker:variant:DesiredInstanceCount",
    PolicyType="TargetTrackingScaling",
    TargetTrackingScalingPolicyConfiguration={
        "TargetValue": 70.0,
        "PredefinedMetricSpecification": {
            "PredefinedMetricType": "SageMakerVariantInvocationsPerInstance"
        }
    }
)
```

## Cost Optimization

### 1. Use Spot Instances for Training

```python
estimator = SKLearn(
    # ... other params ...
    use_spot_instances=True,
    max_wait=7200,  # Max wait time in seconds
    max_run=3600    # Max training time
)
```

**Savings:** Up to 70%

### 2. Right-Size Instances

Start small and scale:
- **Training:** Start with `ml.m5.large`, scale if needed
- **Inference:** Start with `ml.t2.medium` for low traffic

### 3. Delete Endpoints When Not Needed

```python
# Development: Delete after testing
predictor.delete_endpoint()

# Production: Use autoscaling with min=0 during off-hours
```

### 4. Use Batch Transform Instead of Real-Time

For non-real-time workloads, batch transform is much cheaper.

### 5. Use Managed Spot Training

Automatic checkpointing and resume on spot interruptions.

### 6. Multi-Model Endpoints

Host multiple models on one endpoint:

```python
from sagemaker.multidatamodel import MultiDataModel

mdm = MultiDataModel(
    name="multi-model-endpoint",
    model_data_prefix="s3://bucket/models/",
    image_uri=image_uri,
    role=role
)

mdm.deploy(
    initial_instance_count=1,
    instance_type="ml.m5.large"
)
```

### 7. Serverless Inference (Preview)

For intermittent traffic:

```python
from sagemaker.serverless import ServerlessInferenceConfig

serverless_config = ServerlessInferenceConfig(
    memory_size_in_mb=2048,
    max_concurrency=10
)

predictor = model.deploy(
    serverless_inference_config=serverless_config
)
```

### Cost Monitoring

```bash
# View SageMaker costs
aws ce get-cost-and-usage \
  --time-period Start=2025-01-01,End=2025-01-31 \
  --granularity MONTHLY \
  --metrics UnblendedCost \
  --filter file://filter.json
```

`filter.json`:
```json
{
  "Dimensions": {
    "Key": "SERVICE",
    "Values": ["Amazon SageMaker"]
  }
}
```

## Monitoring and Logging

### CloudWatch Metrics

```python
import boto3

cloudwatch = boto3.client("cloudwatch")

response = cloudwatch.get_metric_statistics(
    Namespace="AWS/SageMaker",
    MetricName="ModelLatency",
    Dimensions=[
        {"Name": "EndpointName", "Value": "my-endpoint"},
        {"Name": "VariantName", "Value": "AllTraffic"}
    ],
    StartTime=datetime.now() - timedelta(hours=1),
    EndTime=datetime.now(),
    Period=300,
    Statistics=["Average"]
)
```

### CloudWatch Logs

Training logs:
```bash
aws logs tail /aws/sagemaker/TrainingJobs --follow
```

Endpoint logs:
```bash
aws logs tail /aws/sagemaker/Endpoints/my-endpoint --follow
```

## Troubleshooting

### Training Job Fails

Check logs:
```bash
aws sagemaker describe-training-job --training-job-name my-job
```

Common issues:
- Insufficient IAM permissions
- Invalid S3 paths
- Out of memory (increase instance type)

### Endpoint Deployment Fails

- Check Docker image is valid
- Verify model artifacts exist
- Check instance type availability

### High Latency

- Enable autoscaling
- Use larger instance type
- Optimize model (quantization, pruning)
- Use batch predictions

### Out of Memory

- Reduce batch size
- Use larger instance
- Optimize model size

---

**Next:** [07 - Security Best Practices](07-security.md)

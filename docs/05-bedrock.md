# 05 - Amazon Bedrock Development

## Overview

Amazon Bedrock provides foundation models via API:
- No infrastructure management
- Pay per use
- Multiple model providers
- Built-in security and compliance

## Model Access

### Enable Model Access

1. Open AWS Console → Bedrock → Model access
2. Click "Manage model access"
3. Select models:
   - **Claude 3 Sonnet** (Anthropic)
   - **Claude 3 Haiku** (Anthropic)
   - **Titan Text G1** (Amazon)
   - **Titan Embeddings V2** (Amazon)
   - **Llama 3** (Meta) - if available
4. Submit request
5. Wait for approval (~5 minutes)

### Verify Access

```bash
aws bedrock list-foundation-models --region us-east-1
```

## Supported Regions

Bedrock available in:
- `us-east-1` (N. Virginia) - Most models
- `us-west-2` (Oregon)
- `eu-central-1` (Frankfurt)
- `ap-southeast-1` (Singapore)
- `ap-northeast-1` (Tokyo)

Check current: https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html#bedrock-regions

## Model IDs

### Text Generation

- **Claude 3.5 Sonnet:** `anthropic.claude-3-5-sonnet-20240620-v1:0`
- **Claude 3 Sonnet:** `anthropic.claude-3-sonnet-20240229-v1:0`
- **Claude 3 Haiku:** `anthropic.claude-3-haiku-20240307-v1:0`
- **Llama 3 70B:** `meta.llama3-70b-instruct-v1:0`
- **Titan Text G1:** `amazon.titan-text-express-v1`

### Embeddings

- **Titan Embeddings V2:** `amazon.titan-embed-text-v2:0`
- **Titan Embeddings V1:** `amazon.titan-embed-text-v1`
- **Cohere Embed English:** `cohere.embed-english-v3`

## Python Examples

### Basic Text Generation

```python
import boto3
import json

bedrock_runtime = boto3.client("bedrock-runtime", region_name="us-east-1")

body = json.dumps({
    "anthropic_version": "bedrock-2023-05-31",
    "max_tokens": 1024,
    "messages": [
        {"role": "user", "content": "Explain AWS Lambda"}
    ]
})

response = bedrock_runtime.invoke_model(
    modelId="anthropic.claude-3-sonnet-20240229-v1:0",
    body=body
)

result = json.loads(response["body"].read())
print(result["content"][0]["text"])
```

### Streaming Response

```python
response = bedrock_runtime.invoke_model_with_response_stream(
    modelId="anthropic.claude-3-sonnet-20240229-v1:0",
    body=body
)

for event in response["body"]:
    chunk = json.loads(event["chunk"]["bytes"])
    if chunk["type"] == "content_block_delta":
        print(chunk["delta"]["text"], end="", flush=True)
```

### Converse API (Unified Interface)

```python
response = bedrock_runtime.converse(
    modelId="anthropic.claude-3-sonnet-20240229-v1:0",
    messages=[
        {"role": "user", "content": [{"text": "Hello!"}]}
    ],
    inferenceConfig={
        "maxTokens": 512,
        "temperature": 0.7,
        "topP": 0.9
    }
)

print(response["output"]["message"]["content"][0]["text"])
```

### Embeddings

```python
body = json.dumps({"inputText": "AWS is a cloud platform"})

response = bedrock_runtime.invoke_model(
    modelId="amazon.titan-embed-text-v2:0",
    body=body
)

result = json.loads(response["body"].read())
embeddings = result["embedding"]  # List of floats
print(f"Dimensions: {len(embeddings)}")
```

## LangChain Integration

### Setup

```python
from langchain_aws import ChatBedrock, BedrockEmbeddings

llm = ChatBedrock(
    model_id="anthropic.claude-3-sonnet-20240229-v1:0",
    region_name="us-east-1",
    model_kwargs={"temperature": 0.7, "max_tokens": 512}
)

embeddings = BedrockEmbeddings(
    model_id="amazon.titan-embed-text-v2:0",
    region_name="us-east-1"
)
```

### Simple Chain

```python
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

prompt = ChatPromptTemplate.from_messages([
    ("system", "You are a helpful assistant."),
    ("user", "{input}")
])

chain = prompt | llm | StrOutputParser()
result = chain.invoke({"input": "Explain S3"})
print(result)
```

### RAG Example

```python
from langchain_community.vectorstores import FAISS
from langchain_core.documents import Document

docs = [
    Document(page_content="AWS S3 is object storage"),
    Document(page_content="AWS EC2 provides compute"),
]

vectorstore = FAISS.from_documents(docs, embeddings)
retriever = vectorstore.as_retriever()

# Query
results = retriever.get_relevant_documents("storage service")
print(results[0].page_content)
```

## Running Examples

### From Repository

```bash
cd ai/

# Basic Bedrock examples
poetry run python src/bedrock_example.py

# LangChain examples
poetry run python src/langchain_bedrock_example.py

# Jupyter notebook
poetry run jupyter lab notebooks/bedrock_quickstart.ipynb
```

## Pricing

### Pay-per-use (On-Demand)

- **Claude 3 Sonnet:**
  - Input: $3 per 1M tokens
  - Output: $15 per 1M tokens
- **Claude 3 Haiku:**
  - Input: $0.25 per 1M tokens
  - Output: $1.25 per 1M tokens
- **Titan Embeddings V2:**
  - $0.02 per 1K tokens

### Provisioned Throughput

For high-volume use:
- Purchase model units (MU)
- Guaranteed capacity
- Lower per-token cost at scale

## Rate Limits and Throttling

### Default Limits

- **Requests per minute:** 10-100 (varies by model)
- **Tokens per minute:** 10,000-50,000
- **Concurrent connections:** 10

### Handling Throttles

```python
from botocore.exceptions import ClientError
import time

def invoke_with_retry(bedrock_runtime, model_id, body, max_retries=3):
    for attempt in range(max_retries):
        try:
            response = bedrock_runtime.invoke_model(
                modelId=model_id,
                body=body
            )
            return response
        except ClientError as e:
            if e.response["Error"]["Code"] == "ThrottlingException":
                wait_time = 2 ** attempt
                print(f"Throttled. Waiting {wait_time}s...")
                time.sleep(wait_time)
            else:
                raise
    raise Exception("Max retries exceeded")
```

### Request Limit Increase

AWS Console → Service Quotas → Amazon Bedrock → Request increase

## Security Best Practices

### IAM Policy

Minimal permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream",
        "bedrock:ListFoundationModels"
      ],
      "Resource": "*"
    }
  ]
}
```

### VPC Endpoints

For private access:

```bash
aws ec2 create-vpc-endpoint \
  --vpc-id vpc-xxx \
  --service-name com.amazonaws.us-east-1.bedrock-runtime \
  --subnet-ids subnet-xxx
```

### Encryption

All data encrypted:
- In transit: TLS 1.2+
- At rest: AWS-managed keys

## Monitoring

### CloudWatch Metrics

```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/Bedrock \
  --metric-name Invocations \
  --dimensions Name=ModelId,Value=anthropic.claude-3-sonnet-20240229-v1:0 \
  --start-time 2025-01-01T00:00:00Z \
  --end-time 2025-01-02T00:00:00Z \
  --period 3600 \
  --statistics Sum
```

### CloudWatch Logs

Enable logging:

```bash
aws bedrock put-model-invocation-logging-configuration \
  --logging-config '{
    "cloudWatchConfig": {
      "logGroupName": "/aws/bedrock/modelinvocations",
      "roleArn": "arn:aws:iam::ACCOUNT:role/BedrockLoggingRole"
    },
    "textDataDeliveryEnabled": false,
    "imageDataDeliveryEnabled": false,
    "embeddingDataDeliveryEnabled": false
  }'
```

## Prompt Engineering Tips

### System Prompts

```python
messages = [
    {
        "role": "system",
        "content": "You are a technical writer. Be concise and accurate."
    },
    {
        "role": "user",
        "content": "Explain AWS Lambda"
    }
]
```

### Few-Shot Examples

```python
messages = [
    {"role": "user", "content": "Translate: Hello"},
    {"role": "assistant", "content": "Hola"},
    {"role": "user", "content": "Translate: Goodbye"},
    {"role": "assistant", "content": "Adiós"},
    {"role": "user", "content": "Translate: Thank you"}
]
```

### Temperature and Top-P

```python
inferenceConfig = {
    "temperature": 0.7,  # 0 = deterministic, 1 = creative
    "topP": 0.9,         # Nucleus sampling
    "maxTokens": 1024
}
```

## Troubleshooting

### Model Access Denied

Check model access in console. Some models require approval.

### Region Not Supported

Use `us-east-1`, `us-west-2`, or check docs for availability.

### Throttling

Implement exponential backoff and request limit increase.

### Invalid Model ID

List available models:
```bash
aws bedrock list-foundation-models --region us-east-1 --query 'modelSummaries[*].modelId'
```

---

**Next:** [06 - Amazon SageMaker](06-sagemaker.md)

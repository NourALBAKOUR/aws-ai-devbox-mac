"""
Bedrock Runtime API Examples
Demonstrates basic text generation and embeddings with Amazon Bedrock
"""

import os
import json
import boto3
from botocore.config import Config

# Configure retry behavior
config = Config(
    region_name=os.getenv("AWS_REGION", "us-east-1"),
    retries={"max_attempts": 3, "mode": "adaptive"}
)

bedrock_runtime = boto3.client("bedrock-runtime", config=config)


def list_foundation_models() -> None:
    """List available foundation models in Bedrock."""
    bedrock = boto3.client("bedrock", config=config)
    
    print("Available Foundation Models in Bedrock:\n")
    response = bedrock.list_foundation_models()
    
    for model in response["modelSummaries"]:
        print(f"  • {model['modelId']}")
        print(f"    Provider: {model['providerName']}")
        print(f"    Modalities: {', '.join(model.get('inputModalities', []))}")
        print()


def invoke_claude_text(prompt: str, model_id: str = "anthropic.claude-3-sonnet-20240229-v1:0") -> str:
    """Invoke Claude model for text generation."""
    body = json.dumps({
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 1024,
        "messages": [
            {
                "role": "user",
                "content": prompt
            }
        ]
    })
    
    response = bedrock_runtime.invoke_model(
        modelId=model_id,
        body=body
    )
    
    response_body = json.loads(response["body"].read())
    return response_body["content"][0]["text"]


def invoke_titan_embeddings(text: str, model_id: str = "amazon.titan-embed-text-v2:0") -> list[float]:
    """Generate embeddings using Amazon Titan."""
    body = json.dumps({
        "inputText": text
    })
    
    response = bedrock_runtime.invoke_model(
        modelId=model_id,
        body=body
    )
    
    response_body = json.loads(response["body"].read())
    return response_body["embedding"]


def converse_api_example(user_message: str, model_id: str = "anthropic.claude-3-sonnet-20240229-v1:0") -> str:
    """Use the Converse API for unified model interaction."""
    response = bedrock_runtime.converse(
        modelId=model_id,
        messages=[
            {
                "role": "user",
                "content": [{"text": user_message}]
            }
        ],
        inferenceConfig={
            "maxTokens": 512,
            "temperature": 0.7,
            "topP": 0.9
        }
    )
    
    return response["output"]["message"]["content"][0]["text"]


def converse_with_history(messages: list[dict], user_message: str, model_id: str = "anthropic.claude-3-sonnet-20240229-v1:0") -> tuple[str, list[dict]]:
    """Maintain conversation history with Converse API."""
    messages.append({
        "role": "user",
        "content": [{"text": user_message}]
    })
    
    response = bedrock_runtime.converse(
        modelId=model_id,
        messages=messages,
        inferenceConfig={
            "maxTokens": 512,
            "temperature": 0.7
        }
    )
    
    assistant_message = response["output"]["message"]["content"][0]["text"]
    messages.append({
        "role": "assistant",
        "content": [{"text": assistant_message}]
    })
    
    return assistant_message, messages


if __name__ == "__main__":
    print("=" * 80)
    print("Amazon Bedrock Examples")
    print("=" * 80)
    print()
    
    # Example 1: List models
    # list_foundation_models()
    
    # Example 2: Simple text generation
    print("Example 1: Text Generation with Claude\n")
    prompt = "Explain AWS SageMaker in 2 sentences."
    response = invoke_claude_text(prompt)
    print(f"Prompt: {prompt}")
    print(f"Response: {response}\n")
    
    # Example 3: Embeddings
    print("Example 2: Generate Embeddings with Titan\n")
    text = "Amazon Bedrock provides foundation models via API"
    embeddings = invoke_titan_embeddings(text)
    print(f"Text: {text}")
    print(f"Embedding dimensions: {len(embeddings)}")
    print(f"First 5 values: {embeddings[:5]}\n")
    
    # Example 4: Converse API
    print("Example 3: Converse API\n")
    response = converse_api_example("What are the benefits of serverless architecture?")
    print(f"Response: {response}\n")
    
    # Example 5: Conversation with history
    print("Example 4: Multi-turn Conversation\n")
    conversation = []
    response1, conversation = converse_with_history(conversation, "What is AWS Lambda?")
    print(f"User: What is AWS Lambda?")
    print(f"Assistant: {response1}\n")
    
    response2, conversation = converse_with_history(conversation, "How does it compare to EC2?")
    print(f"User: How does it compare to EC2?")
    print(f"Assistant: {response2}\n")
    
    print("=" * 80)

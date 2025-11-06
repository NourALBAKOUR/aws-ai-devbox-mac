"""
AWS Bedrock Examples
Demonstrates how to use AWS Bedrock for text generation and chat completions
"""

import json
import boto3
from typing import Dict, Any


class BedrockClient:
    """Client for interacting with AWS Bedrock"""
    
    def __init__(self, region_name: str = "us-east-1"):
        """
        Initialize Bedrock client
        
        Args:
            region_name: AWS region name
        """
        self.client = boto3.client(
            service_name="bedrock-runtime",
            region_name=region_name
        )
        self.bedrock = boto3.client(
            service_name="bedrock",
            region_name=region_name
        )
    
    def list_foundation_models(self) -> list:
        """List available foundation models"""
        response = self.bedrock.list_foundation_models()
        return response.get("modelSummaries", [])
    
    def invoke_claude(
        self,
        prompt: str,
        model_id: str = "anthropic.claude-3-sonnet-20240229-v1:0",
        max_tokens: int = 1024,
        temperature: float = 0.7,
    ) -> str:
        """
        Invoke Claude model for text generation
        
        Args:
            prompt: Input prompt
            model_id: Claude model ID
            max_tokens: Maximum tokens to generate
            temperature: Sampling temperature
            
        Returns:
            Generated text
        """
        body = json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": max_tokens,
            "messages": [
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            "temperature": temperature
        })
        
        response = self.client.invoke_model(
            modelId=model_id,
            body=body
        )
        
        response_body = json.loads(response["body"].read())
        return response_body["content"][0]["text"]
    
    def invoke_titan(
        self,
        prompt: str,
        model_id: str = "amazon.titan-text-express-v1",
        max_tokens: int = 512,
        temperature: float = 0.7,
    ) -> str:
        """
        Invoke Amazon Titan model for text generation
        
        Args:
            prompt: Input prompt
            model_id: Titan model ID
            max_tokens: Maximum tokens to generate
            temperature: Sampling temperature
            
        Returns:
            Generated text
        """
        body = json.dumps({
            "inputText": prompt,
            "textGenerationConfig": {
                "maxTokenCount": max_tokens,
                "temperature": temperature,
                "topP": 0.9
            }
        })
        
        response = self.client.invoke_model(
            modelId=model_id,
            body=body
        )
        
        response_body = json.loads(response["body"].read())
        return response_body["results"][0]["outputText"]
    
    def invoke_model_with_streaming(
        self,
        prompt: str,
        model_id: str = "anthropic.claude-3-sonnet-20240229-v1:0",
        max_tokens: int = 1024
    ):
        """
        Invoke model with response streaming
        
        Args:
            prompt: Input prompt
            model_id: Model ID
            max_tokens: Maximum tokens to generate
            
        Yields:
            Text chunks as they are generated
        """
        body = json.dumps({
            "anthropic_version": "bedrock-2023-05-31",
            "max_tokens": max_tokens,
            "messages": [
                {
                    "role": "user",
                    "content": prompt
                }
            ]
        })
        
        response = self.client.invoke_model_with_response_stream(
            modelId=model_id,
            body=body
        )
        
        stream = response.get("body")
        if stream:
            for event in stream:
                chunk = event.get("chunk")
                if chunk:
                    chunk_obj = json.loads(chunk.get("bytes").decode())
                    if chunk_obj["type"] == "content_block_delta":
                        if chunk_obj["delta"]["type"] == "text_delta":
                            yield chunk_obj["delta"]["text"]


def main():
    """Main function demonstrating Bedrock usage"""
    print("AWS Bedrock Examples\n" + "=" * 50)
    
    # Initialize client
    bedrock_client = BedrockClient()
    
    # List available models
    print("\n1. Listing Foundation Models:")
    models = bedrock_client.list_foundation_models()
    for model in models[:5]:  # Show first 5 models
        print(f"  - {model['modelId']}: {model.get('modelName', 'N/A')}")
    
    # Example: Text generation with Claude
    print("\n2. Text Generation with Claude:")
    prompt = "Explain AWS Bedrock in simple terms."
    try:
        response = bedrock_client.invoke_claude(prompt)
        print(f"Prompt: {prompt}")
        print(f"Response: {response}")
    except Exception as e:
        print(f"Error: {e}")
    
    # Example: Streaming response
    print("\n3. Streaming Response with Claude:")
    prompt = "Write a haiku about machine learning."
    try:
        print(f"Prompt: {prompt}")
        print("Response: ", end="", flush=True)
        for chunk in bedrock_client.invoke_model_with_streaming(prompt, max_tokens=100):
            print(chunk, end="", flush=True)
        print()
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()

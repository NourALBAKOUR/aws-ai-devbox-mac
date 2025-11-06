"""
Bedrock RAG (Retrieval-Augmented Generation) Example
Demonstrates how to use Bedrock with knowledge bases
"""

import json
import boto3
from typing import List, Dict, Any


class BedrockRAG:
    """Client for Bedrock with Knowledge Base integration"""
    
    def __init__(self, region_name: str = "us-east-1"):
        """
        Initialize Bedrock RAG client
        
        Args:
            region_name: AWS region name
        """
        self.bedrock_runtime = boto3.client(
            service_name="bedrock-runtime",
            region_name=region_name
        )
        self.bedrock_agent = boto3.client(
            service_name="bedrock-agent-runtime",
            region_name=region_name
        )
    
    def retrieve_and_generate(
        self,
        query: str,
        knowledge_base_id: str,
        model_id: str = "anthropic.claude-3-sonnet-20240229-v1:0",
    ) -> Dict[str, Any]:
        """
        Retrieve information from knowledge base and generate response
        
        Args:
            query: User query
            knowledge_base_id: Knowledge base ID
            model_id: Model ID for generation
            
        Returns:
            Generated response with citations
        """
        response = self.bedrock_agent.retrieve_and_generate(
            input={
                "text": query
            },
            retrieveAndGenerateConfiguration={
                "type": "KNOWLEDGE_BASE",
                "knowledgeBaseConfiguration": {
                    "knowledgeBaseId": knowledge_base_id,
                    "modelArn": f"arn:aws:bedrock:us-east-1::foundation-model/{model_id}"
                }
            }
        )
        
        return {
            "output": response["output"]["text"],
            "citations": response.get("citations", []),
            "session_id": response.get("sessionId")
        }
    
    def query_with_context(
        self,
        query: str,
        context_documents: List[str],
        model_id: str = "anthropic.claude-3-sonnet-20240229-v1:0"
    ) -> str:
        """
        Query with provided context documents
        
        Args:
            query: User query
            context_documents: List of context documents
            model_id: Model ID
            
        Returns:
            Generated response
        """
        context = "\n\n".join(context_documents)
        prompt = f"""Use the following context to answer the question. If you cannot answer based on the context, say so.

Context:
{context}

Question: {query}

Answer:"""
        
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
        
        response = self.bedrock_runtime.invoke_model(
            modelId=model_id,
            body=body
        )
        
        response_body = json.loads(response["body"].read())
        return response_body["content"][0]["text"]


def main():
    """Main function demonstrating RAG usage"""
    print("AWS Bedrock RAG Examples\n" + "=" * 50)
    
    # Initialize client
    rag_client = BedrockRAG()
    
    # Example: Query with context
    print("\n1. Query with Context Documents:")
    context_docs = [
        "AWS Bedrock is a fully managed service that offers foundation models from leading AI companies.",
        "Amazon SageMaker is a fully managed machine learning service for building, training, and deploying ML models.",
        "AWS provides various AI/ML services including Bedrock, SageMaker, Rekognition, and Comprehend."
    ]
    
    query = "What is AWS Bedrock?"
    
    try:
        response = rag_client.query_with_context(query, context_docs)
        print(f"Query: {query}")
        print(f"Response: {response}")
    except Exception as e:
        print(f"Error: {e}")


if __name__ == "__main__":
    main()

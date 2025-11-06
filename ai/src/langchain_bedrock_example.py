"""
LangChain with Amazon Bedrock
Demonstrates LangChain integration for more complex workflows
"""

import os
from langchain_aws import ChatBedrock, BedrockEmbeddings
from langchain_core.messages import HumanMessage, SystemMessage
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

# Set AWS region
os.environ.setdefault("AWS_REGION", "us-east-1")


def simple_chat_example() -> None:
    """Simple chat completion with Claude via LangChain."""
    llm = ChatBedrock(
        model_id="anthropic.claude-3-sonnet-20240229-v1:0",
        region_name=os.getenv("AWS_REGION", "us-east-1"),
        model_kwargs={"temperature": 0.7, "max_tokens": 512}
    )
    
    messages = [
        SystemMessage(content="You are a helpful AWS Solutions Architect."),
        HumanMessage(content="Explain the difference between Amazon Bedrock and SageMaker.")
    ]
    
    response = llm.invoke(messages)
    print("Simple Chat Example:")
    print(f"Response: {response.content}\n")


def chain_example() -> None:
    """Use LangChain LCEL (LangChain Expression Language) for chaining."""
    llm = ChatBedrock(
        model_id="anthropic.claude-3-sonnet-20240229-v1:0",
        region_name=os.getenv("AWS_REGION", "us-east-1"),
        model_kwargs={"temperature": 0.5, "max_tokens": 256}
    )
    
    prompt = ChatPromptTemplate.from_messages([
        ("system", "You are an expert at explaining cloud computing concepts concisely."),
        ("user", "{input}")
    ])
    
    output_parser = StrOutputParser()
    
    # Create chain using LCEL
    chain = prompt | llm | output_parser
    
    result = chain.invoke({"input": "What is Amazon VPC?"})
    print("Chain Example:")
    print(f"Response: {result}\n")


def embeddings_example() -> None:
    """Generate embeddings with LangChain and Bedrock."""
    embeddings = BedrockEmbeddings(
        model_id="amazon.titan-embed-text-v2:0",
        region_name=os.getenv("AWS_REGION", "us-east-1")
    )
    
    texts = [
        "Amazon S3 is object storage built to store and retrieve any amount of data.",
        "Amazon RDS makes it easy to set up, operate, and scale a relational database.",
        "AWS Lambda lets you run code without provisioning servers."
    ]
    
    # Generate embeddings for multiple texts
    vectors = embeddings.embed_documents(texts)
    
    print("Embeddings Example:")
    for i, text in enumerate(texts):
        print(f"  Text {i+1}: {text[:50]}...")
        print(f"  Embedding dim: {len(vectors[i])}, First 3 values: {vectors[i][:3]}")
    print()


def retrieval_qa_example() -> None:
    """Simple retrieval example using embeddings (in-memory)."""
    from langchain_core.documents import Document
    from langchain_community.vectorstores import FAISS
    
    # Sample documents
    docs = [
        Document(page_content="Amazon Bedrock is a fully managed service for foundation models.", metadata={"source": "bedrock"}),
        Document(page_content="Amazon SageMaker helps build, train, and deploy ML models at scale.", metadata={"source": "sagemaker"}),
        Document(page_content="AWS Lambda is a serverless compute service.", metadata={"source": "lambda"}),
    ]
    
    # Create embeddings and vector store
    embeddings = BedrockEmbeddings(
        model_id="amazon.titan-embed-text-v2:0",
        region_name=os.getenv("AWS_REGION", "us-east-1")
    )
    
    vectorstore = FAISS.from_documents(docs, embeddings)
    
    # Query
    query = "What service helps with foundation models?"
    results = vectorstore.similarity_search(query, k=1)
    
    print("Retrieval Example:")
    print(f"Query: {query}")
    print(f"Top result: {results[0].page_content}")
    print(f"Source: {results[0].metadata['source']}\n")


if __name__ == "__main__":
    print("=" * 80)
    print("LangChain + Amazon Bedrock Examples")
    print("=" * 80)
    print()
    
    simple_chat_example()
    chain_example()
    embeddings_example()
    retrieval_qa_example()
    
    print("=" * 80)

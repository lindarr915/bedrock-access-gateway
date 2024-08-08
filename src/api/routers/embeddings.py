from typing import Annotated
import logging

from fastapi import APIRouter, Depends, Body

from api.auth import api_key_auth
from api.models.bedrock import get_embeddings_model
from api.schema import EmbeddingsRequest, EmbeddingsResponse
from api.setting import DEFAULT_EMBEDDING_MODEL

router = APIRouter(
    prefix="/{deployment}/embeddings",
    dependencies=[Depends(api_key_auth)],
)


@router.post("", response_model=EmbeddingsResponse)
async def embeddings(
    deployment: str,
    embeddings_request: Annotated[
        EmbeddingsRequest,
        Body(
            examples=[
                {
                    "model": "cohere.embed-multilingual-v3",
                    "input": ["Your text string goes here"],
                }
            ],
        ),
    ],
):
    logging.debug(f"## Embedding request: {embeddings_request}")
    if (
        not deployment
        or deployment == ""
        or deployment.lower().startswith("text-embedding-")
    ):
        embeddings_request.model = DEFAULT_EMBEDDING_MODEL
    else:
        embeddings_request.model = deployment
    # Exception will be raised if model not supported.
    model = get_embeddings_model(embeddings_request.model)
    return model.embed(embeddings_request)

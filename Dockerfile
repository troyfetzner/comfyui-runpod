# Force build for amd64 (RunPod GPUs are amd64)
FROM --platform=linux/amd64 python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git wget curl build-essential ffmpeg libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Install runpodctl (for 8888 workspace sidecar)
RUN curl -fsSL https://raw.githubusercontent.com/runpod/runpodctl/main/install.sh | bash

# Set working directory
WORKDIR /root

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

WORKDIR /root/ComfyUI

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Extra deps for popular custom nodes (KJNodes, AnimateDiff, IPAdapter, InstantID, InsightFace, etc.)
RUN pip install \
    opencv-python-headless \
    imageio \
    imageio-ffmpeg \
    ffmpeg-python \
    timm \
    einops \
    transformers \
    accelerate \
    safetensors \
    onnxruntime \
    onnxruntime-gpu \
    insightface \
    mediapipe

# Remove default models folder
RUN rm -rf /root/ComfyUI/models
RUN ln -s /workspace/ComfyUI/models /root/ComfyUI/models

# Link custom_nodes to RunPod volume
RUN rm -rf /root/ComfyUI/custom_nodes && \
    ln -s /workspace/ComfyUI/custom_nodes /root/ComfyUI/custom_nodes

# Ensure target dirs exist
RUN mkdir -p /workspace/ComfyUI/models /workspace/ComfyUI/custom_nodes

# Expose ComfyUI port
EXPOSE 8188

# Start both RunPod sidecar (8888) and ComfyUI (8188)
CMD ["bash", "-lc", "runpodctl start & python3 main.py --listen 0.0.0.0 --port 8188"]

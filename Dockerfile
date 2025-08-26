# Rebuild trigger
# Force build for amd64 (RunPod GPUs are amd64)
FROM --platform=linux/amd64 python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git wget curl build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /root

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

WORKDIR /root/ComfyUI

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

# Remove default models folder
RUN rm -rf /root/ComfyUI/models

# Link models to RunPod volume
RUN ln -s /workspace/comfyui/models /root/ComfyUI/models

# Link custom_nodes to RunPod volume
RUN rm -rf /root/ComfyUI/custom_nodes && \
    ln -s /workspace/comfyui/custom_nodes /root/ComfyUI/custom_nodes

# Expose ComfyUI port
EXPOSE 8188

# Start ComfyUI (use python3 explicitly)
CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188"]

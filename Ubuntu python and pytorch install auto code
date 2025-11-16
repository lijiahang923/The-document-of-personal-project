#!/bin/bash

# 脚本：check_python_pytorch.sh
# 功能：检测Python和PyTorch安装情况，获取安装路径，支持虚拟环境

set -e  # 遇到错误立即退出

echo "=== Python和PyTorch环境检测 ==="
echo "检测时间: $(date)"
echo "当前用户: $(whoami)"
echo ""

# 函数：检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 函数：安全获取路径
get_real_path() {
    if [ -e "$1" ]; then
        readlink -f "$1" 2>/dev/null || echo "$1"
    else
        echo "路径不存在"
    fi
}

# 检测当前是否在虚拟环境中
if [ -n "$VIRTUAL_ENV" ]; then
    echo "🔍 检测到虚拟环境: $VIRTUAL_ENV"
    VENV_ACTIVE=true
elif [ -n "$CONDA_PREFIX" ]; then
    echo "🔍 检测到Conda环境: $CONDA_PREFIX"
    VENV_ACTIVE=true
else
    echo "🔍 未检测到激活的虚拟环境"
    VENV_ACTIVE=false
fi

echo ""
echo "--- Python检测 ---"

# 尝试不同的Python命令
PYTHON_COMMANDS=("python" "python3" "python3.11" "python3.12" "python3.10")

PYTHON_PATH=""
PYTHON_VERSION=""
PYTHON_CMD=""

for cmd in "${PYTHON_COMMANDS[@]}"; do
    if command_exists "$cmd"; then
        if $cmd -c "import sys; print('Python检测通过')" >/dev/null 2>&1; then
            PYTHON_CMD="$cmd"
            PYTHON_PATH=$(get_real_path $(which $cmd))
            PYTHON_VERSION=$($cmd -c "import sys; print(sys.version.split()[0])")
            break
        fi
    fi
done

if [ -n "$PYTHON_CMD" ]; then
    echo "✅ Python安装状态: 已安装"
    echo "   Python命令: $PYTHON_CMD"
    echo "   Python路径: $PYTHON_PATH"
    echo "   Python版本: $PYTHON_VERSION"
    
    # 获取Python的site-packages路径
    SITE_PACKAGES=$($PYTHON_CMD -c "import site; print(site.getsitepackages()[0])" 2>/dev/null || $PYTHON_CMD -c "import sysconfig; print(sysconfig.get_path('purelib'))")
    echo "   Site-packages路径: $SITE_PACKAGES"
else
    echo "❌ Python安装状态: 未找到可用的Python解释器"
    exit 1
fi

echo ""
echo "--- PyTorch检测 ---"

# 通过Python检测PyTorch
PYTORCH_INFO=$($PYTHON_CMD << END
import sys
import os

try:
    import torch
    print("INSTALLED")
    print("VERSION:" + torch.__version__)
    print("PATH:" + os.path.dirname(torch.__file__))
    
    # 检测CUDA支持
    if torch.cuda.is_available():
        print("CUDA:AVAILABLE")
        print("CUDA_VERSION:" + torch.version.cuda)
    else:
        print("CUDA:UNAVAILABLE")
        
    # 检测安装的后端
    if hasattr(torch, '__config__'):
        print("BACKEND:" + str(torch.__config__.show()))
    else:
        print("BACKEND:UNKNOWN")
        
except ImportError:
    print("NOT_INSTALLED")
except Exception as e:
    print("ERROR:" + str(e))
END
)

if echo "$PYTORCH_INFO" | grep -q "INSTALLED"; then
    echo "✅ PyTorch安装状态: 已安装"
    
    PYTORCH_VERSION=$(echo "$PYTORCH_INFO" | grep "VERSION:" | cut -d: -f2-)
    PYTORCH_PATH=$(echo "$PYTORCH_INFO" | grep "PATH:" | cut -d: -f2-)
    CUDA_STATUS=$(echo "$PYTORCH_INFO" | grep "CUDA:" | cut -d: -f2)
    CUDA_VERSION=$(echo "$PYTORCH_INFO" | grep "CUDA_VERSION:" | cut -d: -f2- 2>/dev/null || echo "N/A")
    
    echo "   PyTorch版本: $PYTORCH_VERSION"
    echo "   PyTorch路径: $PYTORCH_PATH"
    echo "   CUDA支持: $CUDA_STATUS"
    if [ "$CUDA_STATUS" = "AVAILABLE" ]; then
        echo "   CUDA版本: $CUDA_VERSION"
    fi
    
    # 验证PyTorch基本功能
    echo ""
    echo "--- PyTorch功能验证 ---"
    VALIDATION_RESULT=$($PYTHON_CMD << END
import torch
try:
    # 基本张量操作
    x = torch.tensor([1.0, 2.0, 3.0])
    y = torch.tensor([4.0, 5.0, 6.0])
    z = x + y
    
    # 矩阵乘法
    a = torch.randn(2, 3)
    b = torch.randn(3, 2)
    c = torch.matmul(a, b)
    
    print("SUCCESS:基本张量操作和矩阵乘法测试通过")
    
    # GPU测试（如果可用）
    if torch.cuda.is_available():
        device = torch.device('cuda')
        x_gpu = x.to(device)
        y_gpu = y.to(device)
        z_gpu = x_gpu + y_gpu
        print("SUCCESS:GPU操作测试通过")
    else:
        print("INFO:未检测到GPU，跳过GPU测试")
        
except Exception as e:
    print("ERROR:" + str(e))
END
)
    echo "   $VALIDATION_RESULT"
    
else
    echo "❌ PyTorch安装状态: 未安装"
    echo "   请使用以下命令安装PyTorch:"
    echo "   pip install torch torchvision torchaudio"
fi

echo ""
echo "--- 环境总结 ---"
echo "虚拟环境激活: $VENV_ACTIVE"
if [ "$VENV_ACTIVE" = true ] && [ -n "$VIRTUAL_ENV" ]; then
    echo "虚拟环境路径: $VIRTUAL_ENV"
fi
echo "Python: $PYTHON_VERSION ($PYTHON_PATH)"

if echo "$PYTORCH_INFO" | grep -q "INSTALLED"; then
    echo "PyTorch: $PYTORCH_VERSION ($PYTORCH_PATH)"
else
    echo "PyTorch: 未安装"
fi

echo ""
echo "=== 检测完成 ==="

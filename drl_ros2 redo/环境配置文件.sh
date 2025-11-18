cd ~/projects/drl_ros2_navigation

cat > setup_drl_ros2_environment.sh << 'EOF'
#!/bin/bash
# DRL-ROS2 完整环境配置脚本
# 作者: 基于用户反馈和需求定制
# 功能: 一键配置完整的DRL-ROS2项目环境

set -e  # 遇到错误时退出

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$PROJECT_ROOT/logs/environment_setup_$(date +%Y%m%d_%H%M%S).log"

# 颜色输出函数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

# 创建目录结构
create_directories() {
    log "创建项目目录结构..."
    mkdir -p "$PROJECT_ROOT"/{scripts,logs,configs,backups,temp}
    log "✅ 目录结构创建完成"
}

# 检查系统依赖
check_system_dependencies() {
    log "检查系统依赖..."
    
    local missing_deps=()
    
    # 检查基本命令
    for cmd in python3 pip3 git curl wget; do
        if ! command -v $cmd &> /dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    # 检查ROS2
    if [ ! -f "/opt/ros/humble/setup.bash" ]; then
        warn "ROS2 Humble 未安装或路径不正确"
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        error "缺少系统依赖: ${missing_deps[*]}"
        info "请运行: sudo apt update && sudo apt install ${missing_deps[*]}"
        return 1
    fi
    
    log "✅ 系统依赖检查完成"
    return 0
}

# 创建虚拟环境
setup_virtual_environment() {
    log "设置Python虚拟环境..."
    
    if [ ! -d "$PROJECT_ROOT/drl_ros2_venv" ]; then
        log "创建虚拟环境..."
        python3 -m venv "$PROJECT_ROOT/drl_ros2_venv"
    fi
    
    # 激活虚拟环境
    source "$PROJECT_ROOT/drl_ros2_venv/bin/activate"
    
    # 升级pip
    pip install --upgrade pip
    
    log "✅ 虚拟环境设置完成"
}

# 安装Python依赖
install_python_dependencies() {
    log "安装Python依赖..."
    
    # 安装PyTorch（根据硬件选择）
    if lspci | grep -i nvidia &> /dev/null && nvidia-smi &> /dev/null; then
        log "检测到NVIDIA GPU，安装CUDA版本PyTorch"
        pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
    else
        log "未检测到NVIDIA GPU，安装CPU版本PyTorch"
        pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
    fi
    
    # 安装核心数据科学包
    pip install numpy pandas matplotlib scikit-learn
    
    # 安装项目特定包
    pip install tensorboard opencv-python tqdm albumentations kornia transforms3d
    
    # 安装开发工具
    pip install jupyter ipykernel ipywidgets
    
    log "✅ Python依赖安装完成"
}

# 配置ROS2环境
setup_ros2_environment() {
    log "配置ROS2环境..."
    
    if [ ! -f "/opt/ros/humble/setup.bash" ]; then
        warn "ROS2 Humble 未安装，跳过ROS2配置"
        return 0
    fi
    
    # 配置ROS2环境
    source /opt/ros/humble/setup.bash
    
    # 设置环境变量
    export ROS_DOMAIN_ID=1
    export TURTLEBOT3_MODEL=waffle
    
    # 验证ROS2基本功能
    if command -v ros2 &> /dev/null; then
        if ros2 pkg list &> /dev/null; then
            log "✅ ROS2环境配置成功"
        else
            warn "ROS2包列表命令失败，但环境已配置"
        fi
    else
        warn "ROS2命令不可用，但环境已配置"
    fi
}

# 设置项目环境变量
setup_project_environment() {
    log "设置项目环境变量..."
    
    export DRLNAV_BASE_PATH="$PROJECT_ROOT/DRL-Robot-Navigation-ROS2"
    export GAZEBO_MODEL_PATH="$GAZEBO_MODEL_PATH:$DRLNAV_BASE_PATH/src/turtlebot3_simulations/turtlebot3_gazebo/models"
    
    # 永久保存到bashrc
    if ! grep -q "DRL-ROS2 Project Environment" ~/.bashrc; then
        cat >> ~/.bashrc << 'EOL'

# DRL-ROS2 Project Environment
export DRLNAV_BASE_PATH=~/projects/drl_ros2_navigation/DRL-Robot-Navigation-ROS2
export ROS_DOMAIN_ID=1
export TURTLEBOT3_MODEL=waffle
export GAZEBO_MODEL_PATH=$GAZEBO_MODEL_PATH:~/projects/drl_ros2_navigation/DRL-Robot-Navigation-ROS2/src/turtlebot3_simulations/turtlebot3_gazebo/models
EOL
    fi
    
    log "✅ 项目环境变量设置完成"
}

# 克隆项目代码
clone_project_repository() {
    log "克隆项目代码..."
    
    if [ ! -d "$PROJECT_ROOT/DRL-Robot-Navigation-ROS2" ]; then
        cd "$PROJECT_ROOT"
        git clone https://github.com/reiniscimurs/DRL-Robot-Navigation-ROS2.git
        log "✅ 项目代码克隆完成"
    else
        log "✅ 项目代码已存在"
    fi
}

# 安装ROS2项目依赖
install_ros2_dependencies() {
    log "安装ROS2项目依赖..."
    
    if [ ! -f "/opt/ros/humble/setup.bash" ]; then
        warn "ROS2未安装，跳过ROS2依赖安装"
        return 0
    fi
    
    cd "$DRLNAV_BASE_PATH"
    
    # 安装ROS依赖
    deactivate  # 临时退出虚拟环境
    if command -v rosdep &> /dev/null; then
        rosdep update
        rosdep install -i --from-path src --rosdistro humble -y
    else
        warn "rosdep不可用，跳过ROS依赖安装"
    fi
    source "$PROJECT_ROOT/drl_ros2_venv/bin/activate"  # 重新激活虚拟环境
    
    log "✅ ROS2依赖安装完成"
}

# 构建ROS2工作空间
build_ros2_workspace() {
    log "构建ROS2工作空间..."
    
    if [ ! -f "/opt/ros/humble/setup.bash" ]; then
        warn "ROS2未安装，跳过构建"
        return 0
    fi
    
    cd "$DRLNAV_BASE_PATH"
    
    # 构建项目
    if colcon build; then
        log "✅ ROS2工作空间构建成功"
    else
        warn "完整构建失败，尝试逐个包构建"
        colcon build --packages-select turtlebot3_gazebo || true
        colcon build --packages-select drl_navigation_ros2 || true
    fi
}

# 创建管理脚本
create_management_scripts() {
    log "创建管理脚本..."
    
    # 环境激活脚本
    cat > "$PROJECT_ROOT/activate_project.sh" << 'EOL'
#!/bin/bash
# DRL-ROS2 项目环境激活脚本

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 激活DRL-ROS2项目环境..."
source "$PROJECT_ROOT/drl_ros2_venv/bin/activate"

if [ -f "/opt/ros/humble/setup.bash" ]; then
    source /opt/ros/humble/setup.bash
    echo "✅ ROS2环境已配置"
fi

export DRLNAV_BASE_PATH="$PROJECT_ROOT/DRL-Robot-Navigation-ROS2"
export ROS_DOMAIN_ID=1

echo "🎯 环境激活完成！"
echo "可用命令:"
echo "  ./run_gazebo.sh     # 启动Gazebo仿真"
echo "  ./run_training.sh   # 启动训练"
echo "  ./run_tensorboard.sh # 启动TensorBoard"
EOL

    # Gazebo启动脚本
    cat > "$PROJECT_ROOT/run_gazebo.sh" << 'EOL'
#!/bin/bash
# Gazebo仿真启动脚本

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PROJECT_ROOT/activate_project.sh"

echo "🌍 启动Gazebo仿真..."
ros2 launch turtlebot3_gazebo ros2_drl.launch.py
EOL

    # 训练启动脚本
    cat > "$PROJECT_ROOT/run_training.sh" << 'EOL'
#!/bin/bash
# 训练启动脚本

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PROJECT_ROOT/activate_project.sh"

echo "🎯 启动DRL训练..."
cd "$DRLNAV_BASE_PATH"
python src/drl_navigation_ros2/train.py
EOL

    # TensorBoard启动脚本
    cat > "$PROJECT_ROOT/run_tensorboard.sh" << 'EOL'
#!/bin/bash
# TensorBoard启动脚本

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PROJECT_ROOT/activate_project.sh"

echo "📊 启动TensorBoard..."
cd "$DRLNAV_BASE_PATH"
tensorboard --logdir runs --host 0.0.0.0 --port 6006
EOL

    # 环境检查脚本
    cat > "$PROJECT_ROOT/check_environment.sh" << 'EOL'
#!/bin/bash
# 环境检查脚本

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$PROJECT_ROOT/activate_project.sh"

echo "🔍 运行环境检查..."
python "$PROJECT_ROOT/scripts/environment_checker.py"
EOL

    # 使所有脚本可执行
    chmod +x "$PROJECT_ROOT"/*.sh
    
    log "✅ 管理脚本创建完成"
}

# 创建环境检查器
create_environment_checker() {
    log "创建环境检查器..."
    
    cat > "$PROJECT_ROOT/scripts/environment_checker.py" << 'EOL'
#!/usr/bin/env python3
"""
DRL-ROS2 环境完整性检查器
"""

import sys
import os
import subprocess
import platform

def print_section(title):
    print(f"\n{title}")
    print("=" * 50)

def print_status(name, status, message=""):
    icon = "✅" if status else "❌"
    print(f"{icon} {name:20} {message}")

def check_system():
    print_section("🐧 系统信息")
    print(f"系统: {platform.system()} {platform.release()}")
    print(f"架构: {platform.machine()}")
    print(f"Python: {platform.python_version()}")

def check_virtual_environment():
    print_section("🐍 虚拟环境")
    python_path = sys.executable
    expected_path = os.path.expanduser("~/projects/drl_ros2_navigation/drl_ros2_venv")
    
    if expected_path in python_path:
        print_status("虚拟环境", True, f"路径: {python_path}")
        return True
    else:
        print_status("虚拟环境", False, f"当前: {python_path}, 期望: {expected_path}")
        return False

def check_python_packages():
    print_section("📦 Python包")
    packages = [
        ("torch", "PyTorch"),
        ("torchvision", "TorchVision"),
        ("numpy", "NumPy"),
        ("cv2", "OpenCV"),
        ("tensorboard", "TensorBoard"),
        ("tqdm", "进度条"),
        ("albumentations", "图像增强"),
        ("kornia", "Kornia视觉"),
    ]
    
    all_ok = True
    for pkg, name in packages:
        try:
            module = __import__(pkg)
            version = getattr(module, '__version__', '未知')
            print_status(name, True, version)
        except ImportError:
            print_status(name, False, "缺失")
            all_ok = False
    
    return all_ok

def check_ros2():
    print_section("🤖 ROS2环境")
    
    # 检查ROS2安装
    if not os.path.exists("/opt/ros/humble"):
        print_status("ROS2安装", False, "未找到/opt/ros/humble")
        return False
    
    print_status("ROS2安装", True, "Humble")
    
    # 检查ROS2命令
    try:
        result = subprocess.run(["ros2", "pkg", "list"], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            pkg_count = len([pkg for pkg in result.stdout.strip().split('\n') if pkg])
            print_status("ROS2功能", True, f"{pkg_count}个包")
            
            # 检查必要包
            required = ["turtlebot3_gazebo"]
            available = result.stdout.strip().split('\n')
            for pkg in required:
                if pkg in available:
                    print_status(f"  {pkg}", True)
                else:
                    print_status(f"  {pkg}", False, "缺失")
            return True
        else:
            print_status("ROS2功能", False, "命令执行失败")
            return False
    except Exception as e:
        print_status("ROS2功能", False, f"异常: {e}")
        return False

def check_project():
    print_section("📁 项目结构")
    project_root = os.path.expanduser("~/projects/drl_ros2_navigation")
    
    items = [
        ("drl_ros2_venv", "虚拟环境"),
        ("scripts", "脚本目录"),
        ("logs", "日志目录"),
        ("configs", "配置目录"),
        ("backups", "备份目录"),
        ("DRL-Robot-Navigation-ROS2", "项目代码"),
    ]
    
    all_ok = True
    for dir_name, display_name in items:
        path = os.path.join(project_root, dir_name)
        if os.path.exists(path):
            print_status(display_name, True)
        else:
            print_status(display_name, False)
            all_ok = False
    
    return all_ok

def check_environment_variables():
    print_section("🔧 环境变量")
    
    env_vars = {
        "DRLNAV_BASE_PATH": "项目基础路径",
        "ROS_DOMAIN_ID": "ROS域ID",
        "TURTLEBOT3_MODEL": "TurtleBot3模型",
    }
    
    all_ok = True
    for var, description in env_vars.items():
        value = os.getenv(var)
        if value:
            print_status(description, True, value)
        else:
            print_status(description, False, "未设置")
            all_ok = False
    
    return all_ok

def main():
    print("🔍 DRL-ROS2 环境完整性检查")
    print("=" * 60)
    
    check_system()
    venv_ok = check_virtual_environment()
    packages_ok = check_python_packages()
    ros_ok = check_ros2()
    project_ok = check_project()
    env_vars_ok = check_environment_variables()
    
    print("\n" + "=" * 60)
    
    all_checks = [venv_ok, packages_ok, ros_ok, project_ok, env_vars_ok]
    if all(all_checks):
        print("🎉 所有检查通过！环境准备就绪。")
        print("\n下一步:")
        print("  终端1: ./run_gazebo.sh     # 启动Gazebo")
        print("  终端2: ./run_training.sh   # 启动训练")
        print("  终端3: ./run_tensorboard.sh # 启动监控")
    else:
        print("⚠️  环境需要修复")
        failed_checks = sum(1 for check in all_checks if not check)
        print(f"   {failed_checks} 项检查未通过")
        sys.exit(1)

if __name__ == "__main__":
    main()
EOL

    log "✅ 环境检查器创建完成"
}

# 最终验证
final_validation() {
    log "执行最终验证..."
    
    source "$PROJECT_ROOT/drl_ros2_venv/bin/activate"
    
    if [ -f "/opt/ros/humble/setup.bash" ]; then
        source /opt/ros/humble/setup.bash
    fi
    
    # 运行环境检查
    python "$PROJECT_ROOT/scripts/environment_checker.py"
    
    log "🎉 环境配置完成！"
    log "📝 详细日志: $LOG_FILE"
    
    echo ""
    echo "🚀 快速开始:"
    echo "   source ~/projects/drl_ros2_navigation/activate_project.sh"
    echo "   ./check_environment.sh"
    echo ""
    echo "📚 项目文档:"
    echo "   查看 README.md 获取详细使用说明"
}

# 主执行流程
main() {
    echo "=================================================="
    echo "           DRL-ROS2 环境配置脚本"
    echo "=================================================="
    echo ""
    
    mkdir -p "$PROJECT_ROOT/logs"
    
    # 执行配置步骤
    create_directories
    check_system_dependencies
    setup_virtual_environment
    install_python_dependencies
    setup_ros2_environment
    setup_project_environment
    clone_project_repository
    install_ros2_dependencies
    build_ros2_workspace
    create_management_scripts
    create_environment_checker
    final_validation
}

# 运行主函数
main "$@"
EOF

chmod +x setup_drl_ros2_environment.sh

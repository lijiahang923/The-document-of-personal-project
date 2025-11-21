Virtual Box Ubuntu22.04


Python 3.10

Pytorch

✅ PyTorch已正确安装在虚拟环境 ~/pytorch_project/pytorch_env 中
✅ 版本: 2.9.1+cpu
✅ 状态: 正常工作

(pytorch_env) ljh@ljh-VirtualBox:~$ ./check_python_pytorch.sh
=== Python和PyTorch环境检测 ===
检测时间: Sun Nov 16 07:04:16 PM CST 2025
当前用户: ljh

🔍 检测到虚拟环境: /home/ljh/pytorch_project/pytorch_env

--- Python检测 ---
✅ Python安装状态: 已安装
   Python命令: python
   Python路径: /usr/bin/python3.10
   Python版本: 3.10.12
   Site-packages路径: /home/ljh/pytorch_project/pytorch_env/lib/python3.10/site-packages

--- PyTorch检测 ---
✅ PyTorch安装状态: 已安装
   PyTorch版本: 2.9.1+cpu
   PyTorch路径: /home/ljh/pytorch_project/pytorch_env/lib/python3.10/site-packages/torch
   CUDA支持: UNAVAILABLE

--- PyTorch功能验证 ---
   SUCCESS:基本张量操作和矩阵乘法测试通过
INFO:未检测到GPU，跳过GPU测试

--- 环境总结 ---
虚拟环境激活: true
虚拟环境路径: /home/ljh/pytorch_project/pytorch_env
Python: 3.10.12 (/usr/bin/python3.10)
PyTorch: 2.9.1+cpu (/home/ljh/pytorch_project/pytorch_env/lib/python3.10/site-packages/torch)

=== 检测完成 ===

#使用方式：

# 每次使用前激活虚拟环境
source ~/pytorch_project/pytorch_env/bin/activate

# 然后在激活的环境中工作
python your_script.py
jupyter notebook
# ... 其他命令

# 完成后退出虚拟环境
deactivate

 ~/start_pytorch_project.sh

# 运行Python脚本
python your_script.py

# 启动Jupyter
jupyter notebook

pip install 包名

deactivate

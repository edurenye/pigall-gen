#!/bin/bash -e

# OpenVINO
# https://docs.openvinotoolkit.org/2020.3/_docs_install_guides_installing_openvino_raspbian.html
# https://github.com/opencv/opencv/wiki/Intel's-Deep-Learning-Inference-Engine-backend#raspbian-buster
mkdir -p ${ROOTFS_DIR}/opt/intel
cp -r files/openvino ${ROOTFS_DIR}/opt/intel/
pushd ${ROOTFS_DIR}/opt/intel/openvino
on_chroot << EOF
source /opt/intel/openvino/bin/setupvars.sh
usermod -a -G users "pi"
sh /opt/intel/openvino/install_dependencies/install_NCS_udev_rules.sh
EOF
popd

#
# Download sources
#
DOWNLOAD_DIR=${STAGE_WORK_DIR}/download
mkdir -p ${DOWNLOAD_DIR}
pushd ${DOWNLOAD_DIR}

# opencv sources
wget -nc -nv https://github.com/opencv/opencv/archive/4.3.0.tar.gz

popd

#
# Extract and patch sources
#
EXTRACT_DIR=${ROOTFS_DIR}/usr/src
install -v -d ${EXTRACT_DIR}
pushd ${EXTRACT_DIR}

# Extract OpenCV.
tar xzf "${DOWNLOAD_DIR}/4.3.0.tar.gz"

popd

on_chroot << EOF
pip3 install numpy
EOF

#
# Build
#
pushd ${STAGE_WORK_DIR}
on_chroot << EOF
mkdir build
pushd build
cmake "/usr/src/opencv-4.3.0" \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D WITH_IPP=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D OPENCV_ENABLE_PKG_CONFIG=ON \
    -D PKG_CONFIG_EXECUTABLE="/usr/bin/arm-linux-gnueabihf-pkg-config" \
    -D ENABLE_NEON=ON \
    -D CPU_BASELINE="NEON" \
    -D ENABLE_VFPV3=ON \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D CMAKE_SHARED_LINKER_FLAGS=-latomic \
    -D BUILD_EXAMPLES=OFF \
    -D WITH_INF_ENGINE=ON \
    -D INF_ENGINE_LIB_DIRS="/opt/intel/openvino/inference_engine/lib/armv7l" \
    -D INF_ENGINE_INCLUDE_DIRS="/opt/intel/openvino/inference_engine/include" \
    -D CMAKE_FIND_ROOT_PATH="/opt/intel/openvino" \
    -D ENABLE_CXX11=ON ..
make -j4
make install
ldconfig
popd
EOF
popd


# Server.
cp -r files/webapp "${ROOTFS_DIR}/home/pi/"
install -m 644 files/flask.service "${ROOTFS_DIR}/etc/systemd/system/"

# Get the TensorFlow wheel from https://github.com/PINTO0309/Tensorflow-bin
install -m 644 files/tensorflow-2.2.0-cp37-cp37m-linux_armv7l.whl "${ROOTFS_DIR}/tmp/"

# Install dependencies.
on_chroot << EOF
pip3 install Pillow
pip3 install flask-wtf
pip3 install https://dl.google.com/coral/python/tflite_runtime-2.1.0.post1-cp37-cp37m-linux_armv7l.whl
pip3 install /tmp/tensorflow-2.2.0-cp37-cp37m-linux_armv7l.whl
pip3 install onnx
EOF

on_chroot << EOF
systemctl enable flask.service
EOF

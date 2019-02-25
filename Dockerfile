FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
ENV DEBIAN_FRONTEND noninteractive
# libjasper is not provided for 18.04

# -y 
# apt-get
RUN apt-get -y update
RUN apt-get install -y wget git unzip build-essential cmake git pkg-config curl
#images and videos
RUN apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libxvidcore-dev libx264-dev libxine2-dev
RUN apt-get install -y libjpeg-dev libtiff5-dev libpng-dev
RUN apt-get install -y libv4l-dev v4l-utils
RUN apt-get install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
RUN apt-get install -y libatlas-base-dev gfortran libeigen3-dev
RUN apt-get install -y libgtk2.0-dev 
RUN apt-get clean

# move to work dir
WORKDIR /tmp

# build and install OpenCV
RUN wget https://github.com/opencv/opencv/archive/3.4.0.zip
RUN unzip 3.4.0.zip
RUN mkdir opencv-3.4.0/build
WORKDIR opencv-3.4.0/build
RUN cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=/usr/local \
-D BUILD_CUDA_STUBS=OFF \
-D BUILD_DOCS=OFF \
-D BUILD_EXAMPLES=OFF \
-D BUILD_JASPER=OFF \
-D BUILD_JPEG=ON \
-D BUILD_OPENEXR=OFF \
-D BUILD_PACKAGE=ON \
-D BUILD_PERF_TESTS=OFF \
-D BUILD_PNG=OFF \
-D BUILD_SHARED_LIBS=ON \
-D BUILD_TBB=OFF \
-D BUILD_TESTS=OFF \
-D BUILD_TIFF=OFF \
-D BUILD_WITH_DEBUG_INFO=ON \
-D BUILD_ZLIB=OFF \
-D BUILD_WEBP=OFF \
-D BUILD_opencv_apps=ON \
-D BUILD_opencv_calib3d=ON \
-D BUILD_opencv_core=ON \
-D BUILD_opencv_cudaarithm=OFF \
-D BUILD_opencv_cudabgsegm=OFF \
-D BUILD_opencv_cudacodec=OFF \
-D BUILD_opencv_cudafeatures2d=OFF \
-D BUILD_opencv_cudafilters=OFF \
-D BUILD_opencv_cudaimgproc=OFF \
-D BUILD_opencv_cudalegacy=OFF \
-D BUILD_opencv_cudaobjdetect=OFF \
-D BUILD_opencv_cudaoptflow=OFF \
-D BUILD_opencv_cudastereo=OFF \
-D BUILD_opencv_cudawarping=OFF \
-D BUILD_opencv_cudev=OFF \
-D BUILD_opencv_features2d=ON \
-D BUILD_opencv_flann=ON \
-D BUILD_opencv_highgui=ON \
-D BUILD_opencv_imgcodecs=ON \
-D BUILD_opencv_imgproc=ON \
-D BUILD_opencv_java=OFF \
-D BUILD_opencv_ml=ON \
-D BUILD_opencv_objdetect=ON \
-D BUILD_opencv_photo=ON \
-D BUILD_opencv_python2=OFF \
-D BUILD_opencv_python3=ON \
-D BUILD_opencv_shape=ON \
-D BUILD_opencv_stitching=ON \
-D BUILD_opencv_superres=ON \
-D BUILD_opencv_ts=ON \
-D BUILD_opencv_video=ON \
-D BUILD_opencv_videoio=ON \
-D BUILD_opencv_videostab=ON \
-D BUILD_opencv_viz=OFF \
-D BUILD_opencv_world=OFF \
-D CMAKE_BUILD_TYPE=RELEASE \
-D WITH_1394=ON \
-D WITH_CUBLAS=OFF \
-D WITH_CUDA=OFF \
-D WITH_CUFFT=OFF \
-D WITH_EIGEN=ON \
-D WITH_FFMPEG=ON \
-D WITH_GDAL=OFF \
-D WITH_GPHOTO2=OFF \
-D WITH_GIGEAPI=ON \
-D WITH_GSTREAMER=ON \
-D WITH_GTK=ON \
-D WITH_INTELPERC=OFF \
-D WITH_IPP=ON \
-D WITH_IPP_A=OFF \
-D WITH_JASPER=OFF \
-D WITH_JPEG=ON \
-D WITH_LIBV4L=ON \
-D WITH_OPENCL=ON \
-D WITH_OPENCLAMDBLAS=OFF \
-D WITH_OPENCLAMDFFT=OFF \
-D WITH_OPENCL_SVM=OFF \
-D WITH_OPENEXR=OFF \
-D WITH_OPENGL=ON \
-D WITH_OPENMP=OFF \
-D WITH_OPENNI=OFF \
-D WITH_PNG=ON \
-D WITH_PTHREADS_PF=OFF \
-D WITH_PVAPI=ON \
-D WITH_QT=OFF \
-D WITH_TBB=ON \
-D WITH_TIFF=OFF \
-D WITH_UNICAP=OFF \
-D WITH_V4L=ON \
-D WITH_VTK=OFF \
-D WITH_WEBP=OFF \
-D WITH_XIMEA=OFF \
-D WITH_XINE=ON \
..
RUN cmake --build . --config Release
RUN make install
RUN cd /
RUN rm -rf /tmp/*

# config path
RUN LD_LIBRARY_PATH=/usr/local/lib:/usr/lib; export LD_LIBRARY_PATH
RUN ldconfig

# build darknet
WORKDIR /tmp
RUN git clone https://github.com/AlexeyAB/darknet
WORKDIR /tmp/darknet
RUN sed -ie "s/GPU=0/GPU=1/g" Makefile
RUN sed -ie "s/CUDNN=0/CUDNN=1/g" Makefile
RUN sed -ie "s/CUDNN_HALF=0/CUDNN_HALF=1/g" Makefile
RUN sed -ie "s/OPENCV=0/OPENCV=1/g" Makefile
#for rtx seriese
RUN sed -ie "s/# ARCH= -gencode arch=compute_75/ARCH= -gencode arch=compute_75/g" Makefile
#for geforce 1000 series
#RUN sed -ie "s/# ARCH= -gencode arch=compute_61/ARCH= -gencode arch=compute_61/g" Makefile
RUN make

# download yolo v3 weight file
RUN wget http://pjreddie.com/media/files/darknet53.conv.74  
RUN wget https://pjreddie.com/media/files/yolov3.weights

RUN wget https://pjreddie.com/media/files/yolov3-tiny.weights


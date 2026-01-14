FROM osrf/ros:humble-desktop

# Tell the container to use the C.UTF-8 locale for its language settings
ENV LANG C.UTF-8

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get install -y \
    ros-humble-gazebo-ros-pkgs \
    ros-humble-gazebo-ros2-control \
    ros-humble-ros2-control \
    ros-humble-ros2-controllers \
    ros-humble-joint-state-publisher \
    ros-humble-robot-state-publisher \
    ros-humble-robot-localization \
    ros-humble-xacro \
    ros-humble-tf2-ros \
    ros-humble-tf2-tools \
    ros-humble-rmw-cyclonedds-cpp \
    python3-colcon-common-extensions \
    git \
    && rm -rf /var/lib/apt/lists/*

# Link python3 to python otherwise ROS scripts fail when using the OSRF contianer
RUN ln -s /usr/bin/python3 /usr/bin/python

WORKDIR /ros2_ws/src

RUN git clone https://github.com/grboguz21/fastbot_waypoints
COPY fastbot/ /ros2_ws/src/

WORKDIR /ros2_ws
RUN bash -c "source /opt/ros/humble/setup.bash && colcon build"
RUN echo "source /ros2_ws/install/setup.bash" >> ~/.bashrc

RUN mkdir -p /root/.gazebo/models/fastbot_description && \
    cp -r /ros2_ws/src/fastbot_description/onshape /root/.gazebo/models/fastbot_description/
 
# replace setup.bash in ros_entrypoint.sh
RUN sed -i 's|source "/opt/ros/\$ROS_DISTRO/setup.bash"|source "/ros2_ws/install/setup.bash"|g' /ros_entrypoint.sh

 # Cleanup
RUN rm -rf /root/.cache

# Start a bash shell when the container starts
CMD ["bash"]

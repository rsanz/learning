from setuptools import setup

package_name = 'my_lifecycle_py'

setup(
    name=package_name,
    version='0.1.0',
    packages=[package_name],
    data_files=[
        ('share/ament_index/resource_index/packages',
         ['resource/' + package_name]),
        ('share/' + package_name, ['package.xml']),
        ('share/' + package_name + '/launch', ['launch/lifecycle_demo.launch.py']),
    ],
    install_requires=['setuptools'],
    zip_safe=True,
    maintainer='Developer',
    maintainer_email='dev@example.com',
    description='ROS 2 lifecycle node examples in Python',
    license='Apache-2.0',
    entry_points={
        'console_scripts': [
            'lifecycle_talker   = my_lifecycle_py.lifecycle_talker:main',
            'lifecycle_listener = my_lifecycle_py.lifecycle_listener:main',
            'lifecycle_manager  = my_lifecycle_py.lifecycle_manager:main',
        ],
    },
)

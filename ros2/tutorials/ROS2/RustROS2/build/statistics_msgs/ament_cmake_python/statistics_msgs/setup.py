from setuptools import find_packages
from setuptools import setup

setup(
    name='statistics_msgs',
    version='2.0.3',
    packages=find_packages(
        include=('statistics_msgs', 'statistics_msgs.*')),
)

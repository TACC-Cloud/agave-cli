from setuptools import setup, find_packages

setup(
    name='agave_mock_server',
    version='0.1.0',
    author='alejandrox1',
    packages=find_packages(),
    install_requires=[
        'flask',  
        'flask-restful',
        'pyopenssl',
      ],
)

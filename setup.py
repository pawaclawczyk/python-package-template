import os

from setuptools import setup, find_packages

local_path = os.path.dirname(__file__)
# Fix for tox which manipulates execution pathing
if not local_path:
    local_path = '.'
here = os.path.abspath(local_path)

with open(os.path.join(here, "README.md"), "r") as fh:
    long_description = fh.read()


def read_requirements(name: str = "requirements.txt"):
    with open(os.path.join(here, name), "r") as fh:
        return [req.strip() for req in fh.readlines() if req.strip()]


setup(
    name="{{todo}},
    # The application uses version number `0.0.0` to denote that it's in a pure development phase,
    # and there is no release management process in place.
    version="0.0.0",
    description="{{todo}}",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="{{todo}}",
    author="{{todo}}",
    author_email="{{todo}}",
    # https://pypi.org/classifiers/
    classifiers=[
        "Development Status :: 2 - Pre-Alpha",
        "Environment :: Console",
        "Intended Audience :: Developers",
        "Natural Language :: English",
        "Operating System :: OS Independent",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3 :: Only",
        "Topic :: Utilities",
    ],
    keywords=[],
    packages=find_packages(),
    python_requires=">=3.9, <4",
    install_requires=read_requirements(),
    extras_require={
        "dev": read_requirements("requirements_dev.txt")
    },
    package_data={},
    entry_points={
        "console_scripts": []
    },
    project_urls={
        "Bug Reports": "{{here}}",
        "Source": "{{here}}",
    },
)

# Copyright (c) 2026 AIperture-Labs <xavier.beheydt@gmail.com>
# Doc: https://just.systems/man/en/

## Windows dev bootstrap: winget installers for Git, VulkanSDK, RenderDoc
[windows]
dev-bootstrap: _install-git _install-vulkansdk _install-renderdoc
    
[windows]
_install-git:
    -winget install Git.Git

[windows]
_install-vulkansdk:
    -winget install KhronosGroup.VulkanSDK

[windows]
_install-renderdoc:
    -winget install BaldurKarlsson.RenderDoc
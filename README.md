# tf-modules: Reusable OpenTofu Modules for Homelab Infrastructure

This repository contains reusable OpenTofu modules designed for managing components within my personal homelab infrastructure. These modules serve as standardized building blocks consumed by my `tf-live` repository ([https://github.com/tcpkump/tf-live]).

**NOTE on Repository Mirroring:** My primary repository is hosted on a self-hosted Gitea instance (`git.imkumpy.in`). This GitHub repository is a mirror for components I'm comfortable sharing publicly. You might encounter internal links (e.g., `gitea.imkumpy.in`) that are not accessible externally.

## Overview

The purpose of this repository is to encapsulate common infrastructure patterns into reusable, configurable, and versioned OpenTofu modules. This approach promotes:

*   **Don't Repeat Yourself (DRY):** Avoids duplicating code for similar infrastructure setups.
*   **Consistency:** Ensures infrastructure components are created using the same tested logic.
*   **Abstraction:** Hides the complexity of underlying resource configurations behind a simpler module interface.
*   **Testability:** Modules can be tested individually (see Development & Testing).
*   **Versioning:** Allows infrastructure consuming these modules (`tf-live`) to pin to specific, stable versions.

## Repository Structure

The repository is organized as follows:

```
.
├── flake.lock                   # Nix flake lock file for development environment
├── flake.nix                    # Nix flake definition for development environment
└── modules/                     # Contains all reusable modules
    ├── /                        # Directory for a specific module (e.g., proxmox-talos-k8s-cluster)
    │   ├── main.tf              # Core logic of the module
    │   ├── variables.tf         # Input variable definitions
    │   ├── outputs.tf           # Output value definitions
    │   ├── README.md            # Module-specific documentation
    │   ├── examples/            # Usage examples for the module
    │   │   └── ...              # Example configurations
    │   │       └── *.tftest.hcl # Tests using example configurations
    │   └── ...                  # Other module files (providers.tf, templates, etc.)
    └── ...                      # Other modules
```

## Usage

These modules are intended to be consumed primarily via Git source references in your OpenTofu configurations (like in the `tf-live` repository).

**Key aspects of usage:**

1.  **Source:** Use the Git URL of this repository. Since my primary is Gitea via SSH, the source looks like `git::ssh://git@gitea.imkumpy.in/kumpy/tf-modules.git`. If using the GitHub mirror publicly, it would be `git::https://github.com/tcpkump/tf-modules.git`.
2.  **Subdirectory:** Append `//modules/<module-name>` to the source URL to point to the specific module directory within the repository.
3.  **Versioning:** Append `?ref=<tag_name>` to the source URL to pin the module usage to a specific Git tag (e.g., `?ref=proxmox-talos-k8s-cluster-v1.1.0`). **Using tagged versions is highly recommended** for stability.

**Example:**

```hcl
module "kubernetes_cluster" {
  # Use the appropriate Git URL
  source = "git::ssh://git@gitea.imkumpy.in/kumpy/tf-modules.git//modules/proxmox-talos-k8s-cluster?ref=proxmox-talos-k8s-cluster-v1.1.0"
  # Or using GitHub mirror:
  # source = "git::https://github.com/tcpkump/tf-modules.git//modules/proxmox-talos-k8s-cluster?ref=proxmox-talos-k8s-cluster-v1.1.0"

  # Module-specific variables
  cluster_name    = "homelab-dev-k8s"
  proxmox_node    = "pve"
  control_plane_count = 3
  # ... other required variables specific to proxmox-talos-k8s-cluster module
}
```

Refer to each module's variables.tf and README.md for required and optional input variables.
Prerequisites for Using Modules

* OpenTofu: Version compatible with the modules (check terraform.tf or README.md in the module directory).
* Provider Credentials: The environment calling the module needs credentials for the providers used within the module (e.g., Proxmox API token if using proxmox-talos-k8s-cluster).
* Provider Requirements: Specific providers might be required (e.g., proxmox, kubernetes, helm). These are usually defined within the module's own terraform.tf or providers.tf.


## Development & Testing

This section covers setting up the development environment and the methods used for testing modules within this repository.

### Environment Setup

A consistent development environment is managed using [Nix Flakes](https://nixos.wiki/wiki/Flakes) (`flake.nix`). Most necessary tooling (like specific providers or utility scripts) is defined here.

**Note on OpenTofu Version Management:** While Nix manages most dependencies, OpenTofu itself is managed using [**tenv**](https://github.com/tofuutils/tenv). This tool allows for flexible management of multiple OpenTofu versions and typically installs them in the user's home directory. The Nix flake environment provided by this repository is configured to **detect** if the required OpenTofu version (as managed by `tenv`) is available in your `PATH`. If the correct version is not found, activating the Nix environment (`nix develop` or via `direnv`) should provide guidance or instructions on how to install or switch to the required version using `tenv`. This approach was chosen to leverage `tenv`'s specific version management capabilities.

[Direnv](https://direnv.net/) is used for convenience to automatically load the Nix environment and manage secrets via environment variables when you `cd` into the repository directory.

**To activate the environment:**

1.  Ensure Nix (with Flakes enabled), `direnv`, and `tenv` are installed and operational.
2.  Clone this repository.
3.  Navigate into the repository's root directory.
4.  **(If needed)** Use `tenv install` and `tenv use` to select the OpenTofu version required by this project (check the flake or project documentation if unsure which version).
5.  Create a local `.envrc` file if needed for secrets specific to testing (e.g., provider credentials). Ensure this file is in your `.gitignore`. A basic `.envrc` might just contain:
    ```bash
    # .envrc - Add provider secrets if needed for example testing
    use flake
    # export TF_VAR_provider_token="REDACTED"
    ```
6.  Run `direnv allow` to grant direnv permission to load the environment. This will activate the Nix shell defined in `flake.nix` and ensure the correct OpenTofu version (via `tenv`) is accessible.

Your shell should now have access to the necessary tools for module development and testing.

### Testing Modules

Modules should be tested during development using one or both of the following methods:

1.  **Manual Testing with Examples:**
    Modules typically include usage examples in an `examples/` subdirectory. You can manually run standard OpenTofu commands within these example directories to validate module behavior or test changes during development.

    ```bash
    # Navigate to a specific module's example
    cd modules/<module-name>/examples/basic

    # Ensure necessary provider credentials are available in the environment
    # (e.g., exported via .envrc)

    # Initialize the example configuration
    tofu init

    # Review the planned changes
    tofu plan

    # Apply the configuration to create real resources (use caution!)
    # tofu apply

    # Destroy the created resources when finished testing
    # tofu destroy
    ```

    This is useful for visual inspection and testing specific configurations.

2.  **Automated Testing (`tofu test`):**
    Where `.tftest.hcl` files exist within a module's directory, functionality can be verified using OpenTofu's built-in testing framework. These tests define resources, execute runs, and assert conditions on outputs or state.

    ```bash
    # Navigate to the root directory of the module you want to test
    cd modules/<module-name>

    # Run the tests defined in *.tftest.hcl files
    tofu test
    ```

    This provides a more automated and repeatable way to verify module correctness, suitable for CI/CD pipelines (TODO).

Typical Development Workflow:

1. Create or navigate to the module directory (e.g., modules/my-new-module).
2. Make changes to .tf, variables.tf, outputs.tf, etc.
3. Add or update examples in the examples/ directory.
4. Add or update tests in *.tftest.hcl files.
5. Run tofu fmt and potentially tofu validate.
6. Run tofu test from the module's directory to execute tests.
7. Manually test examples if needed (cd examples/.., tofu init, tofu apply).
8. Commit changes.
9. Create a version tag (see Versioning Strategy).
10. Push commits and tags.

## Versioning Strategy

This repository uses Git tags to version individual modules or the repository state. It is strongly recommended to reference modules using these tags (?ref=tag_name) in your live configurations for stability.

I use module-specific tags (e.g., `proxmox-talos-k8s-cluster-v1.1.0`) when I am ready to release a new version of a
module to one of my environments.

## License

This repository and its contents are licensed under the MIT License. See the LICENSE file for details.

## Disclaimer

These modules are developed primarily for my personal homelab environment. While designed to be reusable, they are provided "AS IS" under the MIT License, without warranty of any kind. They may require adaptation or may not be suitable for all use cases. Please review the module code and documentation thoroughly before use. No direct support is provided.

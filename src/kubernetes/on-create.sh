#!/usr/bin/env bash
set -e

echo "Setting up Kubernetes with DuploCloud..."

# Use devcontainer environment variables with fallbacks
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"
USER_NAME="${_REMOTE_USER:-$(whoami)}"

# Load feature configuration
if [ -f /usr/local/etc/kubernetes-feature.conf ]; then
  source /usr/local/etc/kubernetes-feature.conf
fi

# Check if terminal is interactive
function is_terminal_interactive() {
  # Check if stdin is a terminal and stdout is a terminal
  [ -t 0 ] && [ -t 1 ]
}

# Generate kubeconfig using duploctl
function generate_kubeconfig() {
  local jit="${JIT:-true}"
  
  # Skip if JIT is disabled
  if [ "${jit}" != "true" ]; then
    echo "JIT authentication disabled. Skipping kubeconfig generation."
    echo "Run 'duploctl update_kubeconfig' manually to configure kubectl."
    return 0
  fi
  
  # Check if duploctl is available
  if ! command -v duploctl &> /dev/null; then
    echo "Warning: duploctl not found. Cannot generate kubeconfig."
    echo "Install the duploctl feature or run 'pip install duplocloud-client' to enable JIT."
    echo "You can manually configure kubectl once duploctl is available."
    return 0
  fi

  # Some duploctl distributions may not be compatible with the base image.
  # Treat failures as non-fatal so the container can still start.
  set +e
  duploctl --version >/dev/null 2>&1
  local duploctl_version_rc=$?
  if [ ${duploctl_version_rc} -ne 0 ]; then
    duploctl version >/dev/null 2>&1
    duploctl_version_rc=$?
  fi
  set -e
  if [ ${duploctl_version_rc} -ne 0 ]; then
    echo "Warning: duploctl is installed but failed to execute. Skipping kubeconfig generation."
    return 0
  fi
  
  # Ensure .kube directory exists
  mkdir -p "${USER_HOME}/.kube"
  
  # Build duploctl command arguments
  local cmd_args=("jit" "update_kubeconfig")
  
  # Add admin flag if enabled
  if [ "${JIT_ADMIN}" = "true" ]; then
    cmd_args+=("--admin")
    
    # Add plan flag if admin is true and plan is set
    # Check environment variable first, then feature option
    local plan_name="${DUPLO_PLAN:-${PLAN}}"
    if [ -n "${plan_name}" ]; then
      cmd_args+=("--plan" "${plan_name}")
    fi
  fi
  
  # Add tenant flag if set
  # Check environment variable first, then feature option
  local tenant_name="${DUPLO_TENANT:-${TENANT}}"
  if [ -n "${tenant_name}" ]; then
    cmd_args+=("--tenant" "${tenant_name}")
  fi
  
  # Add interactive flag only if terminal is interactive and flag is enabled
  if [ "${JIT_INTERACTIVE}" = "true" ]; then
    if is_terminal_interactive; then
      cmd_args+=("--interactive")
    else
      echo "Warning: Interactive mode requested but terminal is not interactive."
      echo "Skipping --interactive flag."
    fi
  fi
  
  # Execute duploctl command
  echo "Running: duploctl ${cmd_args[*]}"
  set +e
  duploctl "${cmd_args[@]}"
  local rc=$?
  set -e
  if [ ${rc} -ne 0 ]; then
    echo "Warning: duploctl failed (exit code ${rc}). Skipping kubeconfig generation."
    echo "You can run 'duploctl jit update_kubeconfig' manually after configuring Duplo credentials."
    return 0
  fi
  
  echo "Kubeconfig generated successfully."
  echo "Run 'kubectl config get-contexts' to see available contexts."
}

# Run the function directly
# The onCreateCommand runs as the container user (not root) in most cases
# If running as root, the kubeconfig will be placed in USER_HOME which is correctly detected
generate_kubeconfig

echo "Kubernetes setup complete."

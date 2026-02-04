#!/bin/bash

# Citadel Module Management System
# Handles loading, unloading, dependency resolution, and discovery of Citadel modules

# Module management constants
MODULE_DIR="${MODULE_DIR:-modules}"
LIB_DIR="${LIB_DIR:-lib}"
CONFIG_FILE="${CONFIG_FILE:-/etc/citadel/config.yaml}"

# Module states
MODULE_STATE_LOADED="loaded"
MODULE_STATE_UNLOADED="unloaded"
MODULE_STATE_FAILED="failed"

# Module registry (indexed arrays)
MODULE_NAMES=()
MODULE_FILES=()
MODULE_DEPENDENCIES_ARR=()
MODULE_STATES_ARR=()

# Initialize module management system
module_management_init() {
    echo "Initializing module management system..."

    # Initialize indexed arrays
    MODULE_NAMES=()
    MODULE_FILES=()
    MODULE_DEPENDENCIES_ARR=()
    MODULE_STATES_ARR=()

    # Create module registry
    module_discover

    # Load core modules
    module_load_core

    echo "Module management system initialized"
}

# Discover available modules
module_discover() {
    echo "Discovering available modules..."

    # Clear existing registry
    MODULE_NAMES=()
    MODULE_FILES=()
    MODULE_DEPENDENCIES_ARR=()
    MODULE_STATES_ARR=()

    # Discover unified modules
    if [[ -d "$MODULE_DIR/unified" ]]; then
        for module_file in "$MODULE_DIR/unified"/*.sh; do
            if [[ -f "$module_file" ]]; then
                local module_name
                module_name=$(basename "$module_file" .sh)

                # Extract module metadata
                local description=""
                local dependencies=""
                local version="1.0.0"

                # Read module metadata from comments
                while IFS= read -r line; do
                    if [[ "$line" =~ ^#[[:space:]]*@description[[:space:]]*(.*)$ ]]; then
                        description="${BASH_REMATCH[1]}"
                    elif [[ "$line" =~ ^#[[:space:]]*@dependencies[[:space:]]*(.*)$ ]]; then
                        dependencies="${BASH_REMATCH[1]}"
                    elif [[ "$line" =~ ^#[[:space:]]*@version[[:space:]]*(.*)$ ]]; then
                        version="${BASH_REMATCH[1]}"
                    fi
                done < "$module_file"

                # Register module
                MODULE_NAMES+=("$module_name")
                MODULE_FILES+=("$module_file")
                MODULE_DEPENDENCIES_ARR+=("$dependencies")
                MODULE_STATES_ARR+=("$MODULE_STATE_UNLOADED")

                echo "Discovered unified module: $module_name ($version) - $description"
            fi
        done
    fi

    # Discover library modules
    if [[ -d "$LIB_DIR" ]]; then
        for lib_file in "$LIB_DIR"/*.sh; do
            if [[ -f "$lib_file" && "$(basename "$lib_file")" != "module-management.sh" ]]; then
                local lib_name
                lib_name=$(basename "$lib_file" .sh)

                # Register as library module
                MODULE_NAMES+=("lib-$lib_name")
                MODULE_FILES+=("$lib_file")
                MODULE_DEPENDENCIES_ARR+=("")
                MODULE_STATES_ARR+=("$MODULE_STATE_UNLOADED")

                echo "Discovered library module: lib-$lib_name"
            fi
        done
    fi

    echo "Discovered ${#MODULE_NAMES[@]} modules"
}

# Find module index by name
module_get_index() {
    local module_name="$1"
    local i

    for ((i = 0; i < ${#MODULE_NAMES[@]}; i++)); do
        if [[ "${MODULE_NAMES[$i]}" == "$module_name" ]]; then
            echo "$i"
            return 0
        fi
    done

    echo "-1"
    return 1
}

# Check if module exists
module_exists() {
    local module_name="$1"
    [[ $(module_get_index "$module_name") -ge 0 ]]
}

# Get module file path
module_get_path() {
    local module_name="$1"
    local index
    index=$(module_get_index "$module_name")

    if [[ $index -ge 0 ]]; then
        echo "${MODULE_FILES[$index]}"
        return 0
    fi

    return 1
}

# Get module state
module_get_state() {
    local module_name="$1"
    local index
    index=$(module_get_index "$module_name")

    if [[ $index -ge 0 ]]; then
        echo "${MODULE_STATES_ARR[$index]}"
        return 0
    fi

    echo "$MODULE_STATE_UNLOADED"
}

# Set module state
module_set_state() {
    local module_name="$1"
    local state="$2"
    local index
    index=$(module_get_index "$module_name")

    if [[ $index -ge 0 ]]; then
        MODULE_STATES_ARR[$index]="$state"
        return 0
    fi

    return 1
}

# Get module dependencies
module_get_dependencies() {
    local module_name="$1"
    local index
    index=$(module_get_index "$module_name")

    if [[ $index -ge 0 ]]; then
        echo "${MODULE_DEPENDENCIES_ARR[$index]}"
        return 0
    fi

    return 1
}

# Load core modules that are always required
module_load_core() {
    log_debug "Loading core modules..."

    # Core modules that should always be loaded
    local core_modules=("logging" "utils")

    for module in "${core_modules[@]}"; do
        if module_exists "$module"; then
            module_load "$module"
        else
            echo "Warning: Core module not found: $module"
        fi
    done
}

# Load a module and its dependencies
module_load() {
    local module_name="$1"

    if ! module_exists "$module_name"; then
        echo "Error: Module not found: $module_name"
        return 1
    fi

    # Check if already loaded
    local current_state
    current_state=$(module_get_state "$module_name")
    if [[ "$current_state" == "$MODULE_STATE_LOADED" ]]; then
        echo "Module already loaded: $module_name"
        return 0
    fi

    echo "Loading module: $module_name"

    # Load dependencies first
    local deps
    deps=$(module_get_dependencies "$module_name")
    if [[ -n "$deps" ]]; then
        IFS=',' read -ra DEP_ARRAY <<< "$deps"
        for dep in "${DEP_ARRAY[@]}"; do
            dep=$(echo "$dep" | xargs)  # Trim whitespace
            if ! module_load "$dep"; then
                echo "Error: Failed to load dependency $dep for module $module_name"
                module_set_state "$module_name" "$MODULE_STATE_FAILED"
                return 1
            fi
        done
    fi

    # Load the module
    local module_file
    module_file=$(module_get_path "$module_name")
    if [[ -f "$module_file" ]]; then
        if source "$module_file"; then
            module_set_state "$module_name" "$MODULE_STATE_LOADED"
            echo "Successfully loaded module: $module_name"

            # Call module init function if it exists
            local init_func="${module_name}_init"
            if declare -f "$init_func" >/dev/null 2>&1; then
                if "$init_func"; then
                    echo "Called init function for module: $module_name"
                else
                    echo "Warning: Init function failed for module: $module_name"
                fi
            fi

            return 0
        else
            echo "Error: Failed to source module file: $module_file"
            module_set_state "$module_name" "$MODULE_STATE_FAILED"
            return 1
        fi
    else
        echo "Error: Module file not found: $module_file"
        module_set_state "$module_name" "$MODULE_STATE_FAILED"
        return 1
    fi
}

# Unload a module
module_unload() {
    local module_name="$1"

    if ! module_exists "$module_name"; then
        echo "Error: Module not found: $module_name"
        return 1
    fi

    # Check if loaded
    local current_state
    current_state=$(module_get_state "$module_name")
    if [[ "$current_state" != "$MODULE_STATE_LOADED" ]]; then
        echo "Module not loaded: $module_name"
        return 0
    fi

    echo "Unloading module: $module_name"

    # Call module cleanup function if it exists
    local cleanup_func="${module_name}_cleanup"
    if declare -f "$cleanup_func" >/dev/null 2>&1; then
        if "$cleanup_func"; then
            echo "Called cleanup function for module: $module_name"
        else
            echo "Warning: Cleanup function failed for module: $module_name"
        fi
    fi

    # Mark as unloaded (Bash doesn't support true unloading of sourced functions)
    module_set_state "$module_name" "$MODULE_STATE_UNLOADED"

    echo "Marked module as unloaded: $module_name"
    echo "Warning: Bash modules cannot be truly unloaded. Functions remain in memory."
}

# Load all available modules
module_load_all() {
    echo "Loading all available modules..."

    local loaded_count=0
    local failed_count=0

    for ((i = 0; i < ${#MODULE_NAMES[@]}; i++)); do
        local module_name="${MODULE_NAMES[$i]}"
        if module_load "$module_name"; then
            ((loaded_count++))
        else
            ((failed_count++))
        fi
    done

    echo "Module loading complete: $loaded_count loaded, $failed_count failed"
}

# Unload all loaded modules
module_unload_all() {
    echo "Unloading all modules..."

    local unloaded_count=0

    for ((i = 0; i < ${#MODULE_NAMES[@]}; i++)); do
        local module_name="${MODULE_NAMES[$i]}"
        local current_state
        current_state=$(module_get_state "$module_name")
        if [[ "$current_state" == "$MODULE_STATE_LOADED" ]]; then
            if module_unload "$module_name"; then
                ((unloaded_count++))
            fi
        fi
    done

    echo "Unloaded $unloaded_count modules"
}

# List modules with their status
module_list() {
    local show_details="${1:-false}"

    echo "Available Citadel Modules:"
    echo "=========================="

    for ((i = 0; i < ${#MODULE_NAMES[@]}; i++)); do
        local module_name="${MODULE_NAMES[$i]}"
        local state="${MODULE_STATES_ARR[$i]}"
        local deps="${MODULE_DEPENDENCIES_ARR[$i]}"
        local file_path="${MODULE_FILES[$i]}"

        printf "  %-20s %-10s" "$module_name" "[$state]"

        if [[ "$show_details" == "true" ]]; then
            printf " %s" "$file_path"
            if [[ -n "$deps" ]]; then
                printf " (deps: %s)" "$deps"
            fi
        fi

        echo ""
    done

    echo ""
    echo "Total modules: ${#MODULE_NAMES[@]}"
    echo "Loaded modules: $(module_count_loaded)"
    echo "Failed modules: $(module_count_failed)"
}

# Count loaded modules
module_count_loaded() {
    local count=0
    for state in "${MODULE_STATES_ARR[@]}"; do
        if [[ "$state" == "$MODULE_STATE_LOADED" ]]; then
            ((count++))
        fi
    done
    echo "$count"
}

# Count failed modules
module_count_failed() {
    local count=0
    for state in "${MODULE_STATES[@]}"; do
        if [[ "$state" == "$MODULE_STATE_FAILED" ]]; then
            ((count++))
        fi
    done
    echo "$count"
}

# Check module dependencies
module_check_dependencies() {
    local module_name="$1"
    local deps="${MODULE_DEPENDENCIES[$module_name]}"

    if [[ -z "$deps" ]]; then
        return 0
    fi

    IFS=',' read -ra DEP_ARRAY <<< "$deps"
    for dep in "${DEP_ARRAY[@]}"; do
        dep=$(echo "$dep" | xargs)
        if ! module_exists "$dep"; then
            log_error "Missing dependency for $module_name: $dep"
            return 1
        fi
        if [[ "${MODULE_STATES[$dep]}" != "$MODULE_STATE_LOADED" ]]; then
            log_error "Dependency not loaded for $module_name: $dep"
            return 1
        fi
    done

    return 0
}

# Get module information
module_info() {
    local module_name="$1"

    if ! module_exists "$module_name"; then
        log_error "Module not found: $module_name"
        return 1
    fi

    local state="${MODULE_STATES[$module_name]:-$MODULE_STATE_UNLOADED}"
    local deps="${MODULE_DEPENDENCIES[$module_name]}"
    local file_path="${MODULE_REGISTRY[$module_name]}"

    echo "Module Information: $module_name"
    echo "================================"
    echo "State: $state"
    echo "File: $file_path"
    if [[ -n "$deps" ]]; then
        echo "Dependencies: $deps"
    fi

    # Try to extract description from file
    if [[ -f "$file_path" ]]; then
        local description=""
        while IFS= read -r line; do
            if [[ "$line" =~ ^#[[:space:]]*@description[[:space:]]*(.*)$ ]]; then
                description="${BASH_REMATCH[1]}"
                break
            fi
        done < "$file_path"

        if [[ -n "$description" ]]; then
            echo "Description: $description"
        fi
    fi
}

# Reload a module (unload then load)
module_reload() {
    local module_name="$1"

    log_info "Reloading module: $module_name"

    if module_unload "$module_name" && module_load "$module_name"; then
        log_info "Successfully reloaded module: $module_name"
        return 0
    else
        log_error "Failed to reload module: $module_name"
        return 1
    fi
}

# Get modules by state
module_get_by_state() {
    local target_state="$1"
    local result=()

    for module_name in "${!MODULE_REGISTRY[@]}"; do
        if [[ "${MODULE_STATES[$module_name]}" == "$target_state" ]]; then
            result+=("$module_name")
        fi
    done

    echo "${result[@]}"
}

# Export module functions for external use
export -f module_management_init
export -f module_discover
export -f module_load_core
export -f module_exists
export -f module_get_path
export -f module_get_state
export -f module_load
export -f module_unload
export -f module_load_all
export -f module_unload_all
export -f module_list
export -f module_count_loaded
export -f module_count_failed
export -f module_check_dependencies
export -f module_info
export -f module_reload
export -f module_get_by_state

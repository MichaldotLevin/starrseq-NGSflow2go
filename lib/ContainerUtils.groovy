/**
 * Utility class for handling container configurations
 */
class ContainerUtils {
    
    /**
     * Build a container image URI from configuration
     * 
     * Supports two formats:
     * 1. Simple string: 'biocontainers/fastqc:0.12.1'
     * 2. Map format: [name: 'fastqc', tag: '0.12.1', registry: 'registry.example.com']
     * 
     * @param containerConfig Container configuration (String or Map)
     * @param fallback Fallback container image if config is null or invalid
     * @return Full container image URI
     */
    static String getContainerImage(def containerConfig, String fallback = null) {
        // If null or false, return fallback
        if (!containerConfig) {
            return fallback
        }
        
        // If it's already a string, return as-is
        if (containerConfig instanceof String) {
            return containerConfig
        }
        
        // If it's a map with registry/name/tag, construct the full path
        if (containerConfig instanceof Map) {
            def registry = containerConfig.registry ?: ''
            def name = containerConfig.name ?: ''
            def tag = containerConfig.tag ?: 'latest'
            
            // Validate required fields
            if (!name) {
                System.err.println("WARNING: Container configuration missing 'name' field. Using fallback: ${fallback}")
                return fallback
            }
            
            // Build the full image path
            if (registry) {
                return "${registry}/${name}:${tag}"
            } else {
                return "${name}:${tag}"
            }
        }
        
        // Unknown format, return fallback
        System.err.println("WARNING: Unknown container configuration format. Using fallback: ${fallback}")
        return fallback
    }
}

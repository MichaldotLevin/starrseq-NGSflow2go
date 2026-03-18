/**
 * Utility class for handling resource limits
 */
class ResourceUtils {
    
    /**
     * Check and enforce maximum resource limits
     * 
     * @param obj The requested resource value
     * @param type The resource type ('memory', 'time', or 'cpus')
     * @param params Pipeline parameters containing max limits
     * @return The constrained resource value
     */
    static def checkMax(def obj, String type, def params) {
        if (type == 'memory') {
            try {
                def max_mem = params.max_memory as nextflow.util.MemoryUnit
                return obj.compareTo(max_mem) == 1 ? max_mem : obj
            } catch (all) {
                System.err.println("   ### ERROR ###   Max memory '${params.max_memory}' is not valid! Using default value: ${obj}")
                return obj
            }
        } else if (type == 'time') {
            try {
                def max_t = params.max_time as nextflow.util.Duration
                return obj.compareTo(max_t) == 1 ? max_t : obj
            } catch (all) {
                System.err.println("   ### ERROR ###   Max time '${params.max_time}' is not valid! Using default value: ${obj}")
                return obj
            }
        } else if (type == 'cpus') {
            try {
                return Math.min(obj as int, params.max_cpus as int)
            } catch (all) {
                System.err.println("   ### ERROR ###   Max cpus '${params.max_cpus}' is not valid! Using default value: ${obj}")
                return obj
            }
        }
        return obj
    }
}

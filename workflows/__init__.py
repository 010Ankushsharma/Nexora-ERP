"""Main Workflow Registry."""
from .hr_workflows.hiring import WORKFLOW_REGISTRY as hr_registry
from .finance_workflows.reporting import WORKFLOW_REGISTRY as finance_registry
from .inventory_workflows.replenishment import WORKFLOW_REGISTRY as inventory_registry
from .crm_workflows.qualification import WORKFLOW_REGISTRY as crm_registry

ALL_WORKFLOWS = {
    **hr_registry,
    **finance_registry,
    **inventory_registry,
    **crm_registry
}

def get_workflow(workflow_name: str):
    """Get workflow by name."""
    if workflow_name not in ALL_WORKFLOWS:
        raise ValueError(f"Workflow '{workflow_name}' not found")
    return ALL_WORKFLOWS[workflow_name]

def list_workflows() -> list:
    """List all available workflows."""
    return list(ALL_WORKFLOWS.keys())

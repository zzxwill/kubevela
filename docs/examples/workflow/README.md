1. Apply CRD and Definitions:

    ```
    kubectl apply -f definition.yaml
    ```

    Check Policy and Workflow definitions:

    ```
    kubectl get policy
    kubectl get workflowstep
    ```

    Output:
    ```
    NAME        AGE
    foopolicy   41s

    NAME    AGE
    foowf   49s
    ```

    Check DefinitionRevision:

    ```
    kubectl get definitionrevision
    ```

    Output:

    ```
    NAMESPACE     NAME             REVISION   HASH               TYPE
    default       foopolicy-v1     1          8c340e1beaf9a3fa   Policy
    default       foowf-v1         1          83cf4e8246a89afa   WorkflowStep
    ```

1. Apply Application:

    ```
    kubectl apply -f app.yaml
    ```

1. Check workflow status in Application:

    ```
    kubectl get application first-vela-app -o=jsonpath='{.status.workflow[?(@.name=="my-wf")]}.phase'
    ```

    Output:
    ```
    running
    ```

1. Check Workflow objects:

    ```
    kubectl get foo my-wf -o=jsonpath='{.spec.key}'
    ```

    Output:

    ```
    test
    ```

    This means the resource has been rendered correctly.

1. Check workflow context:

    ```
    kubectl get foo my-wf -o=jsonpath='{.metadata.annotations.app\.oam\.dev/workflow-context}' | jq
    ```

    Output:

    ```json
    {
      "appName": "first-vela-app",
      "appRevision": "first-vela-app-v1",
      "workflowIndex": 0,
      "resourceConfigMap": {
        "name": "first-vela-app-v1"
      }
    }
    ```

1. Patch condition status on workflow object:

    ```
    kubectl patch foo my-wf --type merge --patch "$(cat wf-patch.yaml)"
    ```

    Check workflow object status:

    ```
    kubectl get foo my-wf -o=jsonpath='{.status.conditions[?(@.type=="workflow-finish")]}' | jq
    ```

    Output:

    ```json
    {
      "message": "{\"observedGeneration\":2}",
      "reason": "Succeeded",
      "status": "True",
      "type": "workflow-finish"
    }
    ```

    > Note: The observedGeneration is 2 because the json patch will trigger generation increment.

1.  Check workflow status in Application:

    ```
    kubectl get application first-vela-app -o=jsonpath='{.status.workflow[?(@.name=="my-wf")]}.phase'
    ```

    Output:
    ```
    succeeded
    ```

    The workflow phase has changed from running to succeeded due to the underlying object changing status condition.

1. cleanup:

    ```
    kubectl delete -f app.yaml
    kubectl delete -f definition.yaml
    ```
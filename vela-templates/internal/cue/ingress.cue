// trait template can have multiple outputs in one trait
outputs: service: {
	apiVersion: "v1"
	kind:       "Service"
	metadata:
		name: context.name
	spec: {
		selector: {
			"app.oam.dev/component": context.name
		}
		ports: [
			for k, v in parameter.http {
				port:       v
				targetPort: v
			},
		]
	}
}

outputs: ingress: {
	apiVersion: "networking.k8s.io/v1beta1"
	kind:       "Ingress"
	metadata:
		name: context.name
	spec: {
		rules: [{
			host: parameter.domain
			http: {
				paths: [
					for k, v in parameter.http {
						path: k
						backend: {
							serviceName: context.name
							servicePort: v
						}
					},
				]
			}
		}]
	}
}

parameter: {
	// +usage=Specify the domain you want to expose
	domain: string

	// +usage=Specify the mapping relationship between the http path and the workload port
	http: [string]: int
}

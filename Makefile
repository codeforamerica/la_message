GIT_SHA = $(shell git log -1 --pretty=%h)
WEB_POD = $$(kubectl get pods --selector=app=web --output=jsonpath='{.items[0].metadata.name}')
JOB_POD = $$(kubectl get pods --selector=job-name=migrate --output=jsonpath='{.items[*].metadata.name}')

REGISTRY_PRODUCTION=083756828350.dkr.ecr.us-east-1.amazonaws.com/la-message
REGISTRY_STAGING=317712016930.dkr.ecr.us-east-1.amazonaws.com/medicaid_messages

SSL_CERTIFICATE_PRODUCTION=arn:aws:acm:us-east-1:083756828350:certificate/abe0edb6-c91f-4147-bfb1-79b58c0d308e
SSL_CERTIFICATE_STAGING=arn:aws:acm:us-east-1:317712016930:certificate/6a7c9ff3-6a80-4502-a78e-ff21a3eb478b

docker-build:
	docker build -t la-message .
	docker tag la-message:latest la-message:$(GIT_SHA)
	docker tag la-message:latest $(REGISTRY_PRODUCTION)

docker-push:
	$$(aws ecr get-login --no-include-email --region us-east-1)
	docker push $(REGISTRY_PRODUCTION):latest

kube-migrate:
	kubectl create -f ops/kubernetes/migrate.yml
	kubectl wait --for=condition=Complete --timeout=60s job/migrate # kubectl explain job.status.conditions
	kubectl logs $(JOB_POD)
	kubectl delete job migrate

kube-restart:
	kubectl rollout restart deployment/web

deploy: docker-build docker-push kube-migrate kube-restart

kube-bash:
	kubectl exec -it $(WEB_POD) -- /bin/bash

kube-copy-to-remote:
	kubectl cp $(FROM) $(WEB_POD):$(TO)

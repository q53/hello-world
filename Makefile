NAME = hello-world
VERSION=0.0.1
VERSIONED_NAME = $(NAME)-$(VERSION)

ifeq ($(MINIKUBE),)
KCTL = kubectl
MINIKUBE = $(shell minikube status 2>/dev/null |  awk '/host:/ { print $$2}')
endif
ifneq ($(MINIKUBE),)
KCTL = minikube kubectl -- 
MINIKUBEDRIVER = $(shell minikube profile list | awk  '/minikube/ {print $$4;}')
MINIKUBEIP = $(shell minikube profile list | awk  '/minikube/ {print $$8;}')
endif


all:
	@echo "make compose-start - build and start containers in docker"
	@echo "make kubernetes-deploy - build and start containers in kubernetes"


compose-start: compose-build
	docker-compose up -d
	@echo "*********************************************"
	@echo "hello-world app will be running on 8080 port!"
	@echo "grafana will be running on 3000 port!"

compose-build:
	docker-compose build


compose-remove:
	docker-compose down


kubernetes-deploy: kubernetes-check kubernetes-app-deploy kubernetes-prometheus-deploy kubernetes-grafana-deploy kubernetes-expose


kubernetes-deploy-force: kubernetes-app-deploy kubernetes-prometheus-deploy kubernetes-grafana-deploy kubernetes-expose


kubernetes-app-deploy:
	$(KCTL) apply -f app/kbn-app.yaml


kubernetes-prometheus-deploy:
	$(KCTL) apply -f prometheus/kbn-prometheus.yaml


kubernetes-grafana-deploy:
	$(KCTL) apply -f  grafana/kbn-grafana.yaml


kubernetes-check:
	@$(KCTL) cluster-info | grep -q 'is running' || ( echo "Can't find kubernetes cluster. Run 'make kubernetes-deploy-force' if you know what you are doing!"; exit 1; )
ifneq ($(MINIKUBEDRIVER),none)
	@echo "*************************************************************************************"
	@echo "Driver is not 'none', seems you won't be able reach containers from outside the host!"
	@echo "*************************************************************************************"
endif


kubernetes-expose:
ifneq ($(MINIKUBEIP),)
	sed -e 's/%IP%/$(MINIKUBEIP)/g' app/app-external-svc.yaml.tmpt | $(KCTL) apply -f -
	@echo
	@echo "Hello world will be running on $(MINIKUBEIP):8080!"
	@echo
	sed -e 's/%IP%/$(MINIKUBEIP)/g' grafana/grafana-external-svc.yaml.tmpt | $(KCTL) apply -f -
	@echo
	@echo "Grafana will be running on $(MINIKUBEIP):3000!"
	@echo
else
	@echo
	@echo "We failed to define host IP."
	@echo "You should expose applications by yourself!"
	@echo
endif


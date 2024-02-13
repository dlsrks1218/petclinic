# 환경

해당 프로젝트는 Gradle로 App과 Docker Image를 빌드하여 GitHub 퍼블릭 리포지토리에 푸시하고 Linux 기반의 베어메탈이나 가상머신에 설치된 쿠버네티스 클러스터 또는 MacOS 상 Minikube에 업로드된 이미지를 기반으로 배포하는 프로젝트 입니다.

1. 베어메탈이나 가상머신의 경우, 이미 쿠버네티스가 설치되어 있다고 가정하고 Java 설치 후 Gradle로 빌드 후 배포하여 해당 이미지로 쿠버네티스에 배포하는 시나리오 입니다.
2. MacOS에서 실행하는 경우, Docker Desktop, Minikube를 설치한 후 Gradle로 빌드하여 해당 이미지로 배포하는 시나리오 입니다.

다만 두 환경 모두 로컬 환경에서 실행하므로 (예시:)AWS 환경에서의 Load Balancer 등을 통한 외부 접근이 어려운 관계로, 로컬의 /etc/hosts를 수정하여 임의의 도메인(www.test.com)에 NodePort로 접근하여 확인하도록 합니다.

- 1번의 경우, 실행 완료 후 쿠버네티스 클러스터 내에서 `curl www.test.com:<NODE_PORT>`로 결과를 확인합니다.
- 2번의 경우, 아래 가이드에 따라 실행 완료 후 minikube tunnel 기능을 통해 외부로 노출하여 로컬 브라우저에서 `127.0.0.1:<NODE_PORT>` 혹은 `www.test.com:<NODE_PORT>`로 확인합니다.

- OS : MacOS
- gradle@7 (7.6.4)
- openjdk@17 (17.0.10)

# 실행 방법

1. **포크한 리포지토리를 테스트할 pc에 clone**
    - `git clone https://github.com/dlsrks1218/petclinic.git`
2. **프로젝트 경로로 이동**
    - `cd petclinic`
3. **빌드 혹은 빌드 없이 쿠버네티스 배포**
    - **Local에서 App 및 도커 이미지 빌드를 수행하고자 한다면**
        - **build 스크립트 실행**
            - ./build.sh
            - MacOS의 경우 build.sh 스크립트는 해당 PC에 패키지 매니저 Homebrew를 통해 Java, Docker 가 설치 되어있는지 확인 후 없다면 설치합니다.
            - 설치를 마친 후 Gradle Task를 수행합니다. `./gradlew DBInit clean build jib DBShutDown`
                - Gradle Task 설명
                    - DBInit :  통한 로컬 앱 빌드 시 테스트 task 통과를 위해 기존 `docker-compose up -d` 로 MySQL 컨테이너를 띄웁니다.
                    - build : DBInit으로 MySQL 컨테이너가 실행되면 테스트 코드를 수행하고 build/libs 아래 경로에 jar 파일을 생성합니다.
                    - jib : 해당 태스크를 통해 Dockerfile 없이 이미지를 빌드하여 Docker Hub 리포지토리에 푸시합니다.
                        - Jib는 Maven이나 Gradle 플러그인으로 동작하는 컨테이너 이미지 빌더입니다.
                    - DBShutDown : 빌드 시 테스트 통과를 위한 컨테이너를 `docker-compose down` 을 통해 수행합니다.
    - **빌드 없이 쿠버네티스 배포**
        - 베어메탈이나 가상머신에 설치된 쿠버네티스 클러스터일 경우
            - **`./k8s-deploy.sh` 실행**
                - kubectl을 통해 k8s/app, k8s/db 경로 이하에 있는 리소스를 생성합니다.
                - 현재 쿠버네티스의 노드(단일로 가정)의 IP를 테스트 도메인으로 접근 가능하도록 /etc/hosts를 수정합니다.
                - kubectl을 통해 k8s/ingress 이하 리소스를 생성하여 ingress-controller를 생성합니다.
                - 스크립트의 마지막에 ingress-nginx, mysql, petclinic pod가 ready 상태가 되어있는지 확인하여 스크립트를 종료합니다.
            - **클러스터 내에서 `curl www.test.com:30001` 실행하여 html 확인**
                - VM 기반의 클러스터 (VirtualBox 등) 인 경우, 노드에 대한 포트포워딩을 진행하여 127.0.0.1:<포워딩한 포트> 혹은 로컬 /etc/hosts 수정을 통해 테스트 도메인 -> 127.0.0.1 접근 가능합니다.
        - MacOS의 경우
            - **`./minikube-deploy.sh` 를 실행**
                - 스크립트 설명
                    - Minikube가 설치되어 있는지 확인 후 없다면 설치를 진행합니다.
                    - 다음 단계는 위 k8s-deploy.sh와 같이 k8s/app, k8s/db, k8s/ingress 이하의 리소스를 생성합니다. (ingress 생성 후 ADDRESS가 지정되는데 수분이 걸릴 수 있습니다.)
                    - 위 경우와 달리 Minikube의 경우 MacOS 로컬 브라우저에서 테스트 도메인으로 하여금 Minikube로 접근하도록 /etc/hosts를 수정합니다.
                    - minikube 내 리소스 접근을 위해 kubectl 로 proxy를 데몬으로 실행합니다.
            - **MacOS 터미널에서 `minikube service petclinic` 실행하여 터널링 수행**
                - 127.0.0.1:<NODE_PORT> -> Petclinic의 Nginx Ingress Controller 접근 가능하며 tunnel 명령어 수행시 127.0.0.1: 뒤의 NODE_PORT 정보는 아래 로컬 브라우저 접근 시 필요합니다.
                - 로컬 /etc/hosts에 테스트 도메인 www.test.com이 127.0.0.1로 매핑되어 있습니다
            - **로컬 브라우저에서 www.test.com:<NODE_PORT>로 해당 Petclinic 앱에 접근합니다.**
4. **DB 재실행 시 데이터 보존 확인 및 롤링 업데이트**
    - DB 재실행 시 데이터 보존 확인
        - **`kubectl exec -it mysql-0 /bin/sh`로 파드 접근 후 `mysql -u root -p` 실행, 패스워드는 docker-compose.yaml에 있습니다.**
        - **`use petclinic` DB 접근**
        - **`CREATE TABLE test_table (id INT PRIMARY KEY, value VARCHAR(50));` 테스트 테이블 생성** 
        - **`INSERT INTO test_table (id, value) VALUES (1, 'test data');` 테스트 데이터 입력**
        - **`kubectl delete pod mysql-0` 수행하여 파드 재생성 확인 후 위처럼 mysql 접근하여 데이터 확인**
        - **`select * from test_table` 로 위에서 입력한 데이터 있는지 확인** 
    - 배포할 때 스케일 인,아웃 시 트래픽 유실 안되는 것 확인
        - **`kubectl set image deployment -f k8s/app/deployment.yaml petclinic=dlsrks1218/petclinic:v2`**
            - 최초 실행 시 petclinic 앱은 v1 상태이며, 위 명령어를 통해 v2로 롤링 업데이트를 수행합니다.
        - **`kubectl rollout status deployment petclinic`**
            - 위 명령어로 배포 상태 확인
            - 혹은 로컬 브라우저에서 www.test.com:<NODE_PORT>로 접근 중인 화면을 새로고침하여 정상 작동함 확인
5. **리소스 정리**
    - **`./k8s-cleanup.sh` 실행**
        - 스크립트 설명
            - `kubectl delete -f k8s/db -f k8s/app -f k8s/ingress --recursive` 명령어를 통해 모든 쿠버네티스 리소스를 삭제합니다.
                - 해당 과정에서 validatingwebhookconfiguration.admissionregistration.k8s.io "ingress-nginx-admission" deleted 혹은 pv, pvc 관련 삭제 중 멈춘 것처럼 보인다면 ctrl+c 를 입력 부탁드립니다.
            - MacOS의 경우 minikube 터널링을 위한 프록시 프로세스를 종료합니다.
            - 아닐 경우 테스트 도메인(www.test.com)에 대한 매핑 정보를 /etc/hosts에서 제거합니다.
    - **`minikube stop` (MacOS의 경우만 실행)**

# 요구사항
- gradle을 사용하여 어플리케이션과 도커이미지를 빌드합니다.
    - jib를 통해 도커 이미지 빌드 수행
- 어플리케이션의 log는 host의 `/logs` 에 적재되도록 합니다.
    - 쿠버네티스 노드의 host의 /log 경로에 로그 적재하도록 설정
- 정상 동작 여부를 반환하는 api를 구현하며, 10초에 한번씩 체크합니다.
    - /health API 구현하여 10초마다 체크하도록 설정
        - src/main/java/org/springframework/samples/petclinic/system/HealthCheckController.java
- 종료 시 30초 이내에 프로세스가 종료되지 않으면 SIGKILL로 강제 종료합니다.
    - terminationGracePeriodSeconds 설정하여 확인
- 배포 시 scale-in, out 상황에서 유실되는 트래픽은 없어야 합니다.
    - deployment의 배포 전략을 rolling update로 하여 유실 트래픽 없도록 설정
- 어플리케이션 프로세스는 root 계정이 아닌 uid:999로 실행합니다.
    - jib에서 도커 이미지 빌드 시 uid:999 지정
- DB도 kubernetes에서 실행하며 재 실행 시에도 변경된 데이터는 유실되지 않도록 설정합니다.
    - 테스트 데이터 입력 후 파드 삭제, 재생성 이후 데이터 그대로 있는지 확인
- 어플리케이션과 DB는 cluster domain으로 통신합니다.
    - cluster 내부에서 서비스 명으로 App과 DB 통신하도록 수행
- ingress-controller를 통해 어플리케이션에 접속이 가능해야 합니다.
    - nginx-ingress-controller를 생성하여 어플리케이션 접속
- namespace는 default를 사용합니다.
    - default namespace 실행
- README.md 파일에 실행 방법 및 답변을 기술합니다.

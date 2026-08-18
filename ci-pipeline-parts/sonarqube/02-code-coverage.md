## Coverage files — memorize this table 
| Microservice | Test      | Coverage tool | SonarQube coverage file         |  
| ------------ | --------- | ------------- | ------------------------------- |  
| Java         | JUnit     | JaCoCo        | `target/site/jacoco/jacoco.xml` |  
| Node.js      | Jest      | Istanbul/LCOV | `coverage/lcov.info`            |  
| Python       | pytest    | coverage.py   | `coverage.xml`                  |  
| Go           | `go test` | Go coverage   | `coverage.out`                  |  

## 1. Java  
`sonar-project.properties` 
```properties
sonar.projectKey=company-product-service
sonar.projectName=Notification Service
sonar.sources=src
sonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
```
`pom.xml` 
```xml
<build>
    <plugins>

        <plugin>
            <groupId>org.jacoco</groupId>
            <artifactId>jacoco-maven-plugin</artifactId>
            <version>0.8.11</version>

            <executions>

                <execution>
                    <id>prepare-agent</id>
                    <goals>
                        <goal>prepare-agent</goal>
                    </goals>
                </execution>

                <execution>
                    <id>report</id>
                    <phase>verify</phase>
                    <goals>
                        <goal>report</goal>
                    </goals>
                </execution>

            </executions>
        </plugin>

    </plugins>
</build>
```
Then:  
```bash
mvn clean verify
```
```text
produces:  
target/
├── jacoco.exec
└── site/
    └── jacoco/
        ├── index.html
        ├── jacoco.xml
        └── jacoco.csv
```
**SonarQube uses `jacoco.xml`, not `jacoco.exec`**. SonarSource specifically notes that JaCoCo XML is the supported format for coverage import; the old binary `.exec` property is deprecated.

## Java - GitHub Actions Workflow  
```yaml
name: Java - SonarQube

on:
  pull_request:
    types: [opened, synchronize, reopened]

  push:
    branches:
      - main
      - develop

permissions:
  contents: read
  pull-requests: read

concurrency:
  group: sonar-${{ github.repository }}-${{ github.ref }}
  cancel-in-progress: true

jobs:

  sonarqube:

    name: Build, Test and SonarQube

    runs-on: self-hosted

    steps:

      - name: Checkout
        uses: actions/checkout@v6
        with:
          fetch-depth: 0

      - name: Setup Java
        uses: actions/setup-java@v5
        with:
          distribution: temurin
          java-version: '17'
          cache: maven

      - name: Verify Java and Maven
        run: |
          java -version
          mvn -version

      - name: Build and test with coverage
        run: |
          mvn --batch-mode --no-transfer-progress clean verify

      - name: Verify JaCoCo report
        run: |
          test -f target/site/jacoco/jacoco.xml || {
            echo "ERROR: JaCoCo XML report not found"
            exit 1
          }

      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v7
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ vars.SONAR_HOST_URL }}
```

## 2. Node JS  
Assume:  
```text
Node.js 20
npm
Jest
```
Install Jest if necessary:   
```bash
npm install --save-dev jest
```
Your `package.json` should have something like:  
```json
{
  "scripts": {
    "test": "jest",
    "test:coverage": "jest --coverage"
  }
}
```
Run:  
```bash
npm ci
npm run test:coverage
```
You should get:  
```text
coverage/
└── lcov.info
```
SonarQube uses:  
```text
coverage/lcov.info
```
For JavaScript/TypeScript, SonarQube directly supports LCOV, and `sonar.javascript.lcov.reportPaths` is the current property for both JavaScript and TypeScript. 

Create: `sonar-project.properties`  
```properties
sonar.projectKey=company-notification-service
sonar.projectName=Notification Service
sonar.sources=src
sonar.javascript.lcov.reportPaths=coverage/lcov.info
```

## Node JS - GitHub Actions Workflow
```yaml
name: Node.js - SonarQube

on:
  pull_request:
    types: [opened, synchronize, reopened]

  push:
    branches:
      - main
      - develop

permissions:
  contents: read
  pull-requests: read

concurrency:
  group: sonar-${{ github.repository }}-${{ github.ref }}
  cancel-in-progress: true

jobs:

  sonarqube:

    name: Test and SonarQube

    runs-on: self-hosted

    steps:

      - name: Checkout
        uses: actions/checkout@v6
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v5
        with:
          node-version: '20'
          cache: npm

      - name: Install dependencies
        run: npm ci

      - name: Run tests with coverage
        run: npm run test:coverage

      - name: Verify LCOV report
        run: |
          test -f coverage/lcov.info || {
            echo "ERROR: coverage/lcov.info not found"
            exit 1
          }

      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v7
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ vars.SONAR_HOST_URL }}
```

## 3. Python  
Assume:  
```text
Python 3.12
pytest
coverage.py
```
Install:  
```bash
pip install pytest coverage
```
Run:  
```bash
coverage run -m pytest
coverage xml
```
This produces:  
```text
coverage.xml
```
Then:  
```properties
sonar.projectKey=company-user-service
sonar.projectName=User Service
sonar.sources=src
sonar.python.coverage.reportPaths=coverage.xml
```
SonarQube expects Python coverage in **Cobertura XML** format. `coverage xml` is the standard way to generate it.  

## Python - Github Actions Workflow  
```yaml
name: Python - SonarQube

on:
  pull_request:
    types: [opened, synchronize, reopened]

  push:
    branches:
      - main
      - develop

permissions:
  contents: read
  pull-requests: read

concurrency:
  group: sonar-${{ github.repository }}-${{ github.ref }}
  cancel-in-progress: true

jobs:

  sonarqube:

    name: Test and SonarQube

    runs-on: self-hosted

    steps:

      - name: Checkout
        uses: actions/checkout@v6
        with:
          fetch-depth: 0

      - name: Setup Python
        uses: actions/setup-python@v6
        with:
          python-version: '3.12'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install -r requirements.txt
          pip install pytest coverage

      - name: Run tests with coverage
        run: |
          coverage run -m pytest
          coverage xml

      - name: Verify coverage report
        run: |
          test -f coverage.xml || {
            echo "ERROR: coverage.xml not found"
            exit 1
          }

      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v7
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ vars.SONAR_HOST_URL }}
```

## 4. GO  
For Go:  
```text
go test -coverprofile=coverage.out ./...
```
produces:  
```text
coverage.out
```
create: `sonar-project.properties`
```properties
sonar.projectKey=company-payment-service
sonar.projectName=Payment Service
sonar.sources=.
sonar.go.coverage.reportPaths=coverage.out
```
SonarSource documents **`coverage.out`** as the Go coverage format generated by:   
```bash
go test -coverprofile=coverage.out ./...
```

## GO - GitHub Actions Workflow  
```yaml
name: Go - SonarQube

on:
  pull_request:
    types: [opened, synchronize, reopened]

  push:
    branches:
      - main
      - develop

permissions:
  contents: read
  pull-requests: read

concurrency:
  group: sonar-${{ github.repository }}-${{ github.ref }}
  cancel-in-progress: true

jobs:

  sonarqube:

    name: Test and SonarQube

    runs-on: self-hosted

    steps:

      - name: Checkout
        uses: actions/checkout@v6
        with:
          fetch-depth: 0

      - name: Setup Go
        uses: actions/setup-go@v6
        with:
          go-version: '1.24'
          cache: true

      - name: Download dependencies
        run: |
          go mod download

      - name: Run tests with coverage
        run: |
          go test -coverprofile=coverage.out ./...

      - name: Verify coverage report
        run: |
          test -f coverage.out || {
            echo "ERROR: coverage.out not found"
            exit 1
          }

      - name: SonarQube Scan
        uses: SonarSource/sonarqube-scan-action@v7
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: ${{ vars.SONAR_HOST_URL }}
```











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












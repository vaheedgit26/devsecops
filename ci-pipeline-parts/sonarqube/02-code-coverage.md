## Coverage files — memorize this table 
| Microservice | Test      | Coverage tool | SonarQube coverage file         |  
| ------------ | --------- | ------------- | ------------------------------- |  
| Java         | JUnit     | JaCoCo        | `target/site/jacoco/jacoco.xml` |  
| Node.js      | Jest      | Istanbul/LCOV | `coverage/lcov.info`            |  
| Python       | pytest    | coverage.py   | `coverage.xml`                  |  
| Go           | `go test` | Go coverage   | `coverage.out`                  |  

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

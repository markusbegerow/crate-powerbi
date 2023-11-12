# Power BI Connector for CrateDB

Power BI Connector for CrateDB<br />
Donate link: <a href="https://www.paypal.com/donate?hosted_button_id=7EL8K7ELFWHSY">Buy Me a Coffee?</a>

## What is CrateDB?

CrateDB is a distributed SQL database that makes it simple to store and analyze
massive amounts of data in real-time.

CrateDB offers the benefits of an SQL database *and* the scalability and
flexibility typically associated with NoSQL databases. Modest CrateDB clusters
can ingest tens of thousands of records per second without breaking a
sweat. You can run ad-hoc queries using standard SQL. CrateDB's blazing-fast
distributed query execution engine parallelizes query workloads across the
whole cluster.

## What is Power BI native connector for CrateDB?

The new native Power BI connector for CrateDB connects Power BI Desktop to a cluster of a CrateDB instance.

### Install the connector
There are two ways to install the connector:

- Using the Self-Signed version - not available right now.
- Using the non-signed version, for which you'll have to reduce the security requirements of PowerBi. [There](#Install-the-unsigned-version)

### Install the self signed version - not available right now.

### Install the unsigned version
- You have to enable the "Uncertified connectors" in the Security Options of Power BI:

![image](https://github.com/markusbegerow/crate-powerbi/assets/44146279/a8bc5d82-40c1-4f52-a06a-603da3df81e8)
- Then download the last version of the unsigned connector (*.mez)
- And install this file into your `%USERHOME%\Documents\Power BI Desktop\Custom Connectors` folder.
- Restart Power Bi and the connector should show up in the list.

### How to use it?

* **Step 1**

  > Launch the CrateDB connector. You will find it in the Get Data, Other.

  ![image](https://github.com/markusbegerow/crate-powerbi/assets/44146279/de5c56f0-38ee-41d1-b372-4e1e5c89cf74)

  ![image](https://github.com/markusbegerow/crate-powerbi/assets/44146279/9bfce25c-3e19-42b4-9777-be9789570880)

* **Step 2**

  > If you have not yet set up a CrateDB connection, you'll have to start one now. You have to login with your credentials

  ![image](https://github.com/markusbegerow/crate-powerbi/assets/44146279/83cd9937-4e2c-4006-8d52-4e211ab1f1f1)

  
* **Step 3**

  > Select the data you want to retrieve and validate

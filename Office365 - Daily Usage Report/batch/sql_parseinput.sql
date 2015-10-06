--http://technet.microsoft.com/en-us/library/cc879317(v=sql.105).aspx
--Converted loop process to insert data via #temp table into MERGE statement

MERGE [NetworkReporting].[dbo].[EmailStats] AS TARGET
USING [NetworkReporting].[dbo].[ImportEmailStats] AS SOURCE 
ON (TARGET.[Date] = SOURCE.[Date] AND TARGET.Recipient = SOURCE.Recipient) 
WHEN MATCHED THEN 
UPDATE SET TARGET.Inbound = SOURCE.Inbound, 
	TARGET.Outbound = SOURCE.Outbound,
	TARGET.InboundSize = SOURCE.InboundSize,
	TARGET.OutboundSize = SOURCE.OutboundSize
WHEN NOT MATCHED BY TARGET THEN 
INSERT ([Date], Recipient, Inbound, Outbound, InboundSize, OutboundSize) 
VALUES (SOURCE.[Date], SOURCE.Recipient, SOURCE.Inbound, SOURCE.Outbound, SOURCE.InboundSize, SOURCE.OutboundSize);

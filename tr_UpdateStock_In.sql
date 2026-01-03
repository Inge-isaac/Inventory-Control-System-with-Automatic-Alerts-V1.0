CREATE TRIGGER tr_UpdateStock_In
ON InventoryMovements
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Process only incoming movements ENG/ES Procesar solo movimientos de entrada
    IF EXISTS (SELECT 1 FROM inserted WHERE MovementType = 'IN')
    BEGIN
        MERGE InventoryStock AS target
        USING (
            SELECT ProductID, Quantity
            FROM inserted
            WHERE MovementType = 'IN'
        ) AS src
        ON target.ProductID = src.ProductID

        WHEN MATCHED THEN 
            UPDATE SET 
                target.CurrentStock = target.CurrentStock + src.Quantity,
                target.LastUpdate = GETDATE()

        WHEN NOT MATCHED THEN
            INSERT (ProductID, CurrentStock, LastUpdate)
            VALUES (src.ProductID, src.Quantity, GETDATE());
    END
END

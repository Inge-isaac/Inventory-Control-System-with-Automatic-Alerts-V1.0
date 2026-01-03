CREATE TRIGGER tr_GenerateLowStockAlert
ON InventoryStock
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO InventoryAlerts (ProductID, CurrentStock, ReorderPoint)
    SELECT 
        s.ProductID,
        s.CurrentStock,
        p.ReorderPoint
    FROM InventoryStock s
    INNER JOIN Products p ON s.ProductID = p.ProductID
    WHERE s.CurrentStock < p.ReorderPoint
      AND NOT EXISTS (
            SELECT 1 
            FROM InventoryAlerts a
            WHERE a.ProductID = s.ProductID
              AND a.IsRead = 0
        );
END

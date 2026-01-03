CREATE PROCEDURE sp_GetAlertsPending
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        a.AlertID,
        a.ProductID,
        p.ProductName,
        p.SKU,
        a.CurrentStock,
        a.ReorderPoint,
        a.AlertDate,
        a.IsRead
    FROM InventoryAlerts a
    INNER JOIN Products p ON a.ProductID = p.ProductID
    WHERE a.IsRead = 0
    ORDER BY a.AlertDate;
END

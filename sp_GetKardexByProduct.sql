CREATE PROCEDURE sp_GetKardexByProduct
    @ProductID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Cada IN suma, cada OUT resta
    ;WITH Movs AS (
        SELECT
            m.MovementID,
            m.MovementDate,
            m.MovementType,
            m.Quantity,
            m.Reference,
            -- valor positivo para IN, negativo para OUT
            CASE WHEN m.MovementType = 'IN' THEN m.Quantity ELSE -m.Quantity END AS SignedQty
        FROM InventoryMovements m
        WHERE m.ProductID = @ProductID
    )
    SELECT
        MovementID,
        MovementDate,
        MovementType,
        Quantity,
        Reference,
        SUM(SignedQty) OVER (ORDER BY MovementDate, MovementID
                             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
            + ISNULL((SELECT CurrentStock 
                      FROM InventoryStock s WHERE s.ProductID = @ProductID) 
                     - (SELECT SUM(CASE WHEN MovementType='IN' THEN Quantity ELSE -Quantity END) 
                        FROM InventoryMovements m2 WHERE m2.ProductID = @ProductID AND m2.MovementDate > (SELECT ISNULL(MIN(m3.MovementDate), '1900-01-01') FROM InventoryMovements m3 WHERE m3.ProductID = @ProductID)
                       ), 0) 
            AS RunningBalance
    FROM Movs
    ORDER BY MovementDate, MovementID;
END

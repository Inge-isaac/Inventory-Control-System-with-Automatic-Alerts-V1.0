CREATE TRIGGER tr_UpdateStock_Out
ON InventoryMovements
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Solo movimientos OUT
    IF EXISTS (SELECT 1 FROM inserted WHERE MovementType = 'OUT')
    BEGIN
        -- Validar stock suficiente
        IF EXISTS (
            SELECT 1
            FROM inserted i
            LEFT JOIN InventoryStock s ON i.ProductID = s.ProductID
            WHERE i.MovementType = 'OUT'
              AND (s.CurrentStock < i.Quantity OR s.CurrentStock IS NULL)
        )
        BEGIN
            RAISERROR ('Stock insuficiente para realizar la salida.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        -- Actualizar stock
        UPDATE s
        SET 
            s.CurrentStock = s.CurrentStock - i.Quantity,
            s.LastUpdate = GETDATE()
        FROM InventoryStock s
        INNER JOIN inserted i
            ON s.ProductID = i.ProductID
        WHERE i.MovementType = 'OUT';
    END
END

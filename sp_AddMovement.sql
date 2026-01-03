CREATE PROCEDURE sp_AddMovement
    @ProductID INT,
    @MovementType VARCHAR(10), -- 'IN' or 'OUT'
    @Quantity INT,
    @Reference VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- si ocurre error, hace rollback automático

    IF @Quantity <= 0
    BEGIN
        THROW 50001, 'La cantidad debe ser mayor que 0.', 1;
    END

    IF @MovementType NOT IN ('IN','OUT')
    BEGIN
        THROW 50002, 'MovementType inválido. Use ''IN'' o ''OUT''.', 1;
    END

    BEGIN TRAN;

    BEGIN TRY
        -- Verificar que el producto exista
        IF NOT EXISTS (SELECT 1 FROM Products WHERE ProductID = @ProductID)
        BEGIN
            THROW 50003, 'ProductID no encontrado.', 1;
        END

        -- Para movimientos OUT, bloquear la fila de stock y validar existencia/saldo
        IF @MovementType = 'OUT'
        BEGIN
            -- Intentamos obtener fila de stock con bloqueo para evitar race conditions
            DECLARE @currentStock INT;

            SELECT @currentStock = s.CurrentStock
            FROM InventoryStock s WITH (UPDLOCK, HOLDLOCK)
            WHERE s.ProductID = @ProductID;

            IF @currentStock IS NULL OR @currentStock < @Quantity
            BEGIN
                THROW 50004, 'Stock insuficiente para realizar la salida.', 1;
            END
        END

        -- Insertar movimiento (los triggers se encargan de ajustar InventoryStock)
        INSERT INTO InventoryMovements (ProductID, MovementType, Quantity, MovementDate, Reference)
        VALUES (@ProductID, @MovementType, @Quantity, GETDATE(), @Reference);

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRAN;

        DECLARE @errnum INT = ERROR_NUMBER();
        DECLARE @errmsg NVARCHAR(4000) = ERROR_MESSAGE();
        THROW @errnum, @errmsg, 1;
    END CATCH
END

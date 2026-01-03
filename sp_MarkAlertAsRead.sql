CREATE PROCEDURE sp_MarkAlertAsRead
    @AlertID INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE InventoryAlerts
    SET IsRead = 1
    WHERE AlertID = @AlertID;
END

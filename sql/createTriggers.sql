-- 1. Создать триггер на добавление новой записи заказа. Проверить, действительно ли яхта, которую пытаются арендовать, на данный момент есть в наличии (нет других действительных договоров по этой яхте) и что ее техническое состояние позволяет сдавать ее в прокат (последняя проверка была сделана после окончания предыдущей аренды и не более месяца назад). Если хотя бы одно из этих условий не выполнено, не создавать запись о заказе, выбрасывать соответствующее исключение.

CREATE FUNCTION checkTakenInspection(id INT, date DATE DEFAULT CURRENT_DATE)
    RETURNS BOOLEAN
    LANGUAGE plpgsql
    AS
$$
BEGIN
    RETURN EXISTS (SELECT YachtId
        FROM VRent
        WHERE (VRent.YachtId = id
            AND (date > StartDate)
            AND ((ReturnDate IS NULL) AND (date < EndDate)
            OR (ReturnDate IS NOT NULL) AND (date < ReturnDate))));
END;
$$
;

CREATE FUNCTION checkTakenRent(id INT, date DATE DEFAULT CURRENT_DATE)
    RETURNS BOOLEAN
    LANGUAGE plpgsql
    AS
$$
BEGIN
    RETURN EXISTS (SELECT YachtId
        FROM VRent
        WHERE (VRent.YachtId = id
            AND (date >= StartDate)
            AND ((ReturnDate IS NULL) AND (date <= EndDate)
            OR (ReturnDate IS NOT NULL) AND (date <= ReturnDate))));
END;
$$
;

CREATE FUNCTION checkAvailable(id INT, checkingDate DATE DEFAULT CURRENT_DATE)
    RETURNS BOOLEAN
    LANGUAGE plpgsql
    AS
$$
DECLARE
    inspected BOOLEAN;
    taken BOOLEAN;
    lastUsed DATE;
BEGIN
    IF (checkTakenRent(id, checkingDate)) THEN
        RETURN false;
    END IF;
    lastUsed := (SELECT MAX(ReturnDate)
        FROM VRent
        WHERE (VRent.YachtId = id)
            AND (ReturnDate <= checkingDate));
    inspected := EXISTS (SELECT YachtId
        FROM VInspection
        WHERE (VInspection.YachtId = id
            AND StatusOk
            AND (lastUsed IS NULL
                OR Date > lastUsed)
            AND Date > checkingDate - 30));
    RETURN (inspected);
END;
$$
;

CREATE FUNCTION AddRentFunction()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS
$$
BEGIN
    IF checkAvailable(NEW.YachtId, NEW.StartDate) THEN
        RETURN NEW;
    ELSE
        RAISE EXCEPTION 'The yacht with id=% is either taken or not inspected on %!', NEW.YachtId, NEW.StartDate;
    END IF;
END;
$$
;

CREATE TRIGGER AddRentTrigger
    BEFORE INSERT ON Rent
    FOR EACH ROW
    EXECUTE FUNCTION AddRentFunction();

-- 2. Создать триггер на обновление информации о проверке состояния яхты. В случае, когда информация обновляется для яхты, находящейся в прокате, изменения в базу не вносить, выбрасывать исключение.

CREATE FUNCTION AddInspectionFunction()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS
$$
BEGIN
    IF checkTakenInspection(NEW.YachtId, NEW.Date) THEN
        RAISE EXCEPTION 'The yacht with id=% is taken on %!', NEW.YachtId, NEW.Date;
    ELSIF (EXISTS (SELECT VInspection.YachtId FROM VInspection
        WHERE (VInspection.YachtId = NEW.YachtId
        AND VInspection.Date = NEW.Date AND VInspection.Type = NEW.Type))) THEN
        RAISE EXCEPTION 'The yacht with id=% was already inspected on %!', NEW.YachtId, NEW.Date;
    ELSE
        RETURN NEW;
    END IF;
END;
$$
;

CREATE TRIGGER AddInspectionTrigger
    BEFORE INSERT ON Inspection
    FOR EACH ROW
    EXECUTE FUNCTION AddInspectionFunction();

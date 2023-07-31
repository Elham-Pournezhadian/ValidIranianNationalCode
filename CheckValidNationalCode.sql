SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
-- Firouzi
--تابع بررسی معتبر بودن کد ملی 

CREATE FUNCTION dbo.[ufn_ValidNationalID]
(
    @NationalID CHAR(10)
)
RETURNS BIT
AS
BEGIN

    DECLARE @National_ID_Validation_Result BIT = 1; --true;  

    IF LEN(@NationalID) > 10
    BEGIN

        SET @National_ID_Validation_Result = 0; --false;

        RETURN @National_ID_Validation_Result;

    END;

    --تکمیل کمبود احتمالی صفرهای سمت چپ کد ملی

    SET @NationalID = REPLICATE('0', 10 - LEN(@NationalID)) + @NationalID;

    -- اندازه کد ملی نباید بیشتر از ده کاراکتر باشد

    -- کد ملی تنها باید شامل ارقام 0 تا 9 باشد

    IF ISNUMERIC(@NationalID + '.0e0') = 0
    BEGIN

        SET @National_ID_Validation_Result = 0; --false;

        RETURN @National_ID_Validation_Result;

    END;

    --بیش از دو صفر در سمت چپ کد ملی معتبر نیست

    IF SUBSTRING(@NationalID, 1, 1) = 0
       AND SUBSTRING(@NationalID, 2, 1) = 0
       AND SUBSTRING(@NationalID, 3, 1) = 0
    BEGIN

        SET @National_ID_Validation_Result = 0; --false;

        RETURN @National_ID_Validation_Result;

    END;

    --تمام ارقام کد ملی نمی‏تواند یکسان باشد

    IF (
           @NationalID = '0000000000'
           OR @NationalID = '1111111111'
           OR @NationalID = '2222222222'
           OR @NationalID = '3333333333'
           OR @NationalID = '4444444444'
           OR @NationalID = '5555555555'
           OR @NationalID = '6666666666'
           OR @NationalID = '7777777777'
           OR @NationalID = '8888888888'
           OR @NationalID = '9999999999'
       )
    BEGIN

        SET @National_ID_Validation_Result = 0; --false;


        RETURN @National_ID_Validation_Result;



    END;


    --مقدار خانه کنترل باید صحیح باشد

    -- خانه کنترل رقم سمت راست می‏باشد. در صورتی که باقیمانده مجموع ضرب موقعیت در مقدار

    -- خانه‏ها کنتر از دو باشد همین مقدار باقیمانده باید در خانه کنترل قرار گرفته باشد و در غیر اینصورت

    -- تفاضل یازده با باقیمانده فوق مقدار خانه کنترل را تشکیل می دهد 

    BEGIN



        DECLARE @b AS INT;


        SET @b
            = ((10 * SUBSTRING(@NationalID, 1, 1) + 9 * SUBSTRING(@NationalID, 2, 1) + 8 * SUBSTRING(@NationalID, 3, 1)
                + 7 * SUBSTRING(@NationalID, 4, 1) + 6 * SUBSTRING(@NationalID, 5, 1) + 5
                * SUBSTRING(@NationalID, 6, 1) + 4 * SUBSTRING(@NationalID, 7, 1) + 3 * SUBSTRING(@NationalID, 8, 1)
                + 2 * SUBSTRING(@NationalID, 9, 1)
               ) % 11
              );

        DECLARE @ControlBit AS TINYINT = SUBSTRING(@NationalID, 10, 1);


        IF @b < 2
        BEGIN


            IF @ControlBit != @b
                SET @National_ID_Validation_Result = 0; --false;

        END;


        IF @b >= 2
        BEGIN

            IF @ControlBit != 11 - @b
                SET @National_ID_Validation_Result = 0;



        END;

    END;


    RETURN @National_ID_Validation_Result;

END;
GO

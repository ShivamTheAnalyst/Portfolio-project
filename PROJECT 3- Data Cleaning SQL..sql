--Selecting Housing data from Portfolio project database.
select *
from [portfolio project]..[Housing data]

--Changing the sale date.
 select SaleDate
from [portfolio project]..[Housing data]

--It has time in the end which serves no purpose ,Hence we are taking that off
select SaleDate, CONVERT(Date,SaleDate)
from [portfolio project]..[Housing data] 

--We need to update this in our Housing Data table.
--Update [portfolio project]..[Housing data] 
--Set SaleDate = Convert(Date,SaleDate);  --MUST READ AND CHECK.

--But the Sale date column was not affected, So we are using ALTER TABLE METHOD
ALTER TABLE [portfolio project]..[Housing data]
add SaleDate_new date ;

--Updating it in our housing data
Update [portfolio project]..[Housing data] 
Set SaleDate_new  = Convert(Date,SaleDate);

select SaleDate_new
from [portfolio project]..[Housing data];

--Now we can remove that SalesDate column.
-------------------------------------------------------------------------------------

--Populate Property Address Data

select PropertyAddress
from [portfolio project]..[Housing data]; --Looking at the property address column.

select PropertyAddress
from [portfolio project]..[Housing data]
where PropertyAddress is null 

-- Checking if PropertyAddress have any null entries.

select *
from [portfolio project]..[Housing data]
order by ParcelID

-- WE noticed that the parcelID  should be same as the  property_address 
-- So we can basically say if a particular parcel_id  has an address and the same parcel_id but different Unique_id does not have an address,
--we can populate it with the address of precious same parcel_id but with different Unique_id, cause we know they are going to be the same.

--Creating a self join.
select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress, a.[UniqueID ],b.[UniqueID ]
from [portfolio project]..[Housing data] a
join [portfolio project]..[Housing data] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where b.PropertyAddress is null ;

--Exaclty what we wanted.

--Now populating the Null values in b.PropertyAddress (USING THE ISNULL METHOD , ISNULL(expression, alt_value),
--Expression-The expression to test whether is NULL , alt_value -  The value to return if expression is NULL.

select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress, a.[UniqueID ],b.[UniqueID ] ,  ISNUll(b.PropertyAddress ,a.PropertyAddress) 
from [portfolio project]..[Housing data] a
join [portfolio project]..[Housing data] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null ;

--Updating it in our table

Update a
set PropertyAddress = ISNULL(a.PropertyAddress , b.PropertyAddress)
from [portfolio project]..[Housing data] a
join [portfolio project]..[Housing data] b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null ;

select PropertyAddress
from [portfolio project]..[Housing data]
where PropertyAddress is null ; 
-- NO NULL VALUES IN PROPERTYADDRESS,, HENCE OUR QUERY WORKED.


--Breaking out address into indiviual columns (Address , City, State)
 select PropertyAddress
 from [portfolio project]..[Housing data]

 --What we noticed is that it has the address , the city
 
 select 
 SUBSTRING( PropertyAddress , 1, CHARINDEX(',', PropertyAddress) -1) as Corrected_Address
 , SUBSTRING( PropertyAddress ,CHARINDEX(',', PropertyAddress) +1 , Len(PropertyAddress)) as Corrected_Address
  from [portfolio project]..[Housing data]
--We have used the CHARINDEX and SUBSTRING METHOD -w3schools website for explanation of any SQL Function.
-- WHen separating the rest of the address using substring method,now we are not starting from the first position, we are starting from the comma part.
--Len(PropertyAddress)) because we dont know how much long the address will be to cover the last part of address, so we are using the lengh 
-- of propertyaddress as a limit.
--We cant separate two values into from one column without creating 2 new columns, so we need to update our data
--(USIng alter table and update)

ALTER TABLE [portfolio project]..[Housing data]
add PropertysplitAddress Nvarchar(255) ;          --Here we are adding a new column in our housing data.

update [portfolio project]..[Housing data]
Set PropertysplitAddress = SUBSTRING(PropertyAddress , 1, CHARINDEX(',', PropertyAddress) -1)    --and here we are specifing what will come in this column.

--First split address added in the data and set also.

ALTER TABLE [portfolio project]..[Housing data]
add PropertysplitCity Nvarchar(255) ;

Update [portfolio project]..[Housing data]
set PropertysplitCity = SUBSTRING( PropertyAddress ,CHARINDEX(',', PropertyAddress) +1 , Len(PropertyAddress));

--Adding the PropertysplitCity column and filling it.

select *
from [portfolio project]..[Housing data];

--Checking the updated data, It will appear at the end.

--Now we will look at the owner address
select OwnerAddress
from [portfolio project]..[Housing data];

--WE need to separate the address, the city , the state - we can use substring and charindex method here, 
--WE will use PARSENAME ('object_name' , object_piece ) here.
-- check_-https://docs.microsoft.com/en-us/sql/t-sql/functions/parsename-transact-sql?view=sql-server-ver15

select 
PARSENAME(OwnerAddress , 1)
from [portfolio project]..[Housing data];

--It will not work as parsename look for periods, not for commas.

select 
PARSENAME (replace(OwnerAddress ,',' , '.'), 3) --Using replace method to replace ',' in place adding '.'
,PARSENAME (replace(OwnerAddress ,',' , '.'), 2)
,PARSENAME (replace(OwnerAddress ,',' , '.'), 1)
from [portfolio project]..[Housing data];

--It worked - the starnge part about parsename is that it work backwards.


--same , adding the columns to our data and updating our data.

ALTER TABLE [portfolio project]..[Housing data]
add OwnersplitAddress Nvarchar(255) ;

Update [portfolio project]..[Housing data]
set OwnersplitAddress = PARSENAME (replace(OwnerAddress ,',' , '.'), 3)



ALTER TABLE [portfolio project]..[Housing data]
add OwnersplitCity Nvarchar(255) ;

Update [portfolio project]..[Housing data]
set OwnersplitCity =PARSENAME (replace(OwnerAddress ,',' , '.'), 2) 



ALTER TABLE [portfolio project]..[Housing data]
add OwnersplitState Nvarchar(255) ;

Update [portfolio project]..[Housing data]
set OwnersplitState = PARSENAME (replace(OwnerAddress ,',' , '.'), 1)

--Checking the columns in our data
select *
FROM [portfolio project]..[Housing data];

---------------------------------------
-- Change Y and N  to Yes and No in "Sold as vacant" field.

select distinct(SoldAsVacant) , Count(SoldAsVacant)
from [portfolio project]..[Housing data]
Group by SoldAsVacant
Order by 2; --2 here represents the second item we entered in select.

Select SoldAsVacant   --SQL CASE EXplanation-https://www.w3schools.com/sql/sql_case.asp
,Case
 when SoldAsVacant = 'Y' then'Yes'
 when SoldAsVacant = 'N' then 'No' 
 Else SoldAsVacant
 END 
from [portfolio project]..[Housing data];

Update [portfolio project]..[Housing data]
set SoldAsVacant = Case
 when SoldAsVacant = 'Y' then'Yes'
 when SoldAsVacant = 'N' then 'No' 
 Else SoldAsVacant
 END 

--------------------------------------------------------
--Removing the duplicates
--USing CTE

select *,
 --BOuncer- Will do it later

--Deleting unused column.(Best practice dont do it into your raw data)
--Deleting any columns you want

ALTER TABLE [portfolio project]..[Housing data]  
Drop column OwnerAddress , TaxDistrict , PropertyAddress , SaleDate --IT will remove the column from your Raw data.


Select *
from [portfolio project]..[Housing data];


--Cleaning data
--to make it standardized
--Ro make the data easy to read
--make it clean 















from [portfolio project]..[Housing data]



	


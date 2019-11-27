mysqldump -uroot -p123456 -A -R -E --triggers --master-data=2 --single-transaction --set-gtid-purged=OFF >/temp/full.mysqldump


create table t_100w(id int,num int,k1 char(2),k2 char(4),dt timestamp);
delimiter //
create procedure rand_data(in num int)
begin
declare str char(62) default 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
declare str2 char(2);
declare str4 char(4);
DECLARE i INT DEFAULT 0;
WHILE i < num DO
SET str2 = concat(substring(str, 1+FLOOR(RAND()*61),1),substring(str, 1+FLOOR(RAND()*61),1));
SET str4 = concat(substring(str, 1+FLOOR(RAND()*61),2),substring(str, 1+FLOOR(RAND()*61),2));
SET i = i +1;
insert into t_100w values (i,floor(rand()*num),str2,str4,now());
end while;
end;
//
delimiter;

call rand_data(1000000);

select count(*) from ht.t_100w;

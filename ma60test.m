function ma60test(inputcode,startdate,enddate,a,b)
close all;
w=windmatlab;
[data,~,~,timex,~,~]=w.wsi(inputcode,'close',startdate,enddate,'BarSize=1;periodstart=09:15:00;periodend=15:15:00;Fill=Previous');
time=timex-693960;
%%
%均线设置
SS=20;
LL=60;
[ma20,ma60]=movavg(data,SS,LL);
ma60(1:LL-1)=data(1:LL-1);
ma20(1:SS-1)=data(1:SS-1);

%%
%仓位pos
pos=zeros(length(data),1);
%初始资金
money=0;
%日收益记录
rd=zeros(length(data),1);
%乘数
scale=1;
%操作信号
%五分钟末图上标记
timet=zeros(length(data),1);
pricet=zeros(length(data),1);
sgt=zeros(length(data),1);
pricec=zeros(length(data),1);
timet(:)=nan;
pricet(:)=nan;
pricec(:)=nan;
sgt(:)=nan;


%%
%模拟交易
t=LL;
while t>=LL && t<=length(data)-mod(length(data),5)-5
    %此刻的信号
    sb=data(t)>data(t-1) && data(t)>ma60(t) ;
    ss=data(t)<data(t-1) && data(t)<ma60(t) ;
    %补时间t
    if mod(t,5)~=0
        re=5-mod(t,5);
    else
        re=0;
    end
    
    %5分钟末状态
    if t+re<=length(data)-mod(length(data),5)
        above=data(t+re)>=ma60(t+re);
        below=data(t+re)<=ma60(t+re);
    end
    
    %①触发条件的情况
    %买入条件
    if sb==1 && pos(t-1)~=1
        %空仓开多1手
        if pos(t-1)==0
            pos(t:t+re-1)=1;
            timet(t)=time(t);
            pricet(t)=data(t);
            sgt(t)=1;
            %检验五分钟后状态
            if above==1
                pos(t+re)=1;
            else
                pos(t+re)=0;
                sgt(t+re)=0;
                pricec(t+re)=data(t+re);
            end
            rd(t+1:t+re)=(data(t+1:t+re)-data(t:t+re-1))*scale;
            t=t+re+1;
            continue;
        end
        %平空头开多1手
        if pos(t-1)==-1
            pos(t:t+re-1)=1;
            timet(t)=time(t);
            pricet(t)=data(t);
            sgt(t)=1;
            rd(t)=(data(t-1)-data(t))*scale;
            %检验五分钟后状态
            if above==1
                pos(t+re)=1;
            else
                pos(t+re)=-1;
                sgt(t+re)=0;
                pricec(t+re)=data(t+re);
            end
            rd(t+1:t+re)=(data(t+1:t+re)-data(t:t+re-1))*scale;
            t=t+re+1;
            continue;
        end
    end
    
    %卖出条件
    if ss==1 && pos(t-1)~=-1
        %空仓开空1手
        if pos(t-1)==0
            pos(t:t+re-1)=-1;
            timet(t)=time(t);
            pricet(t)=data(t);
            sgt(t)=-1;
            %检验五分钟后状态
            if below==1
                pos(t+re)=-1;
            else
                pos(t+re)=0;
                sgt(t+re)=0;
                pricec(t+re)=data(t+re);
            end
            rd(t+1:t+re)=-(data(t+1:t+re)-data(t:t+re-1))*scale;
            t=t+re+1;
            continue;
        end
        %平多头开空1手
        if pos(t-1)==1
            pos(t:t+re-1)=-1;
            timet(t)=time(t);
            pricet(t)=data(t);
            sgt(t)=-1;
            rd(t)=(data(t)-data(t-1))*scale;
            %检验五分钟后状态
            if below==1
                pos(t+re)=-1;
            else
                pos(t+re)=1;
                sgt(t+re)=0;
                pricec(t+re)=data(t+re);
            end
            rd(t+1:t+re)=-(data(t+1:t+re)-data(t:t+re-1))*scale;
            t=t+re+1;
            continue;
        end
    end
    
    %②未触发条件的情况
    if pos(t-1)==1
        pos(t)=1;
        rd(t)=(data(t)-data(t-1))*scale;
        t=t+1;
    end
    if pos(t-1)==-1
        pos(t)=-1;
        rd(t)=(data(t-1)-data(t))*scale;
        t=t+1;
    end
    if pos(t-1)==0
        pos(t)=0;
        rd(t)=0;
        t=t+1;
    end
end

%最后一小段，全部平掉
if t>=length(data)-mod(length(data),5)-5+1 && t<=length(data)
    timet(t)=time(t-1);
    pricet(t)=data(t-1);
    sgt(t)=2;
    if pos(t-1)==1
        pos(t-1:length(data))=0;
        rd(t:length(data))=0;
        rd(t-1)=(data(t-1)-data(t-2))*scale;
    end
    if pos(t-1)==-1
        pos(t-1:length(data))=0;
        rd(t:length(data))=0;
        rd(t-1)=-(data(t-1)-data(t-2))*scale;
    end
end

%%
%累计收益
ttr=cumsum(rd);
ttr=ttr+money;

%%
%最大回撤
maxd=zeros(length(data),1);
for t=LL:length(data)
    c=max(ttr(1:t));
    if c==ttr(t)
        maxd(t)=0;
    else
        if c>0
            maxd(t)=100*(ttr(t)-c)/c;
        else
            maxd(t)=0;
        end
    end
    maxd=abs(maxd);
end


ry=(sum(rd)/100)/length(data)*4*60*365;
disp(['年化收益=',num2str(100*ry),'%'])

%%
%五分钟效果展示
data5=data(5:5:length(data)-mod(length(data),5));
ttr5=ttr(5:5:length(data)-mod(length(data),5));
pos5=pos(5:5:length(data)-mod(length(data),5));
time5=time(5:5:length(data)-mod(length(data),5));
ma605=ma60(5:5:length(data)-mod(length(data),5));
maxd5=maxd(5:5:length(data)-mod(length(data),5));
sgt5=zeros(length(data5),1);
sgt5(:)=nan;
pricet5=zeros(length(data5),1);
pricet5(:)=nan;
timet5=zeros(length(data5),1);
timet5(:)=nan;
%制作5分钟sg信号
for i=1:length(data5)
    if sgt(5*i)~=0
        sgt5(i)=max(sgt(5*i-4:5*i));
    else
        sgt5(i)=0;
    end
end

%制作5分钟操作价格时间信号
for i=2:length(pricet5)
    pricet5(i)=max(pricet(5*i-4:5*i));
    timet5(i)=max(timet(5*i-4:5*i));
end

%%
%输出excel 5分钟
if a==1
    result5=[time5,data5,ma605,sgt5,pos5,ttr5,maxd5,timet5,pricet5];
    ttitle={'time5','close price5','ma605','signal5','position5','total return5','max withdraw5','执行时刻','执行价格'};
    showcase5=[ttitle;num2cell(result5)];
    save show5 showcase5;
    xlswrite(['回测',inputcode(1:5),'.xlsx'],showcase5,'sheet1')
    %输出excel 1分钟
    result=[time,data,ma60,pos,rd,ttr,maxd];
    ttitle={'time','close price','ma60','position','daily return','total return','max withdraw'};
    showcase=[ttitle;num2cell(result)];
    save show showcase
    save alldata
    xlswrite(['回测',inputcode(1:5),'.xlsx'],showcase,'sheet2')
end


%%
%画图
if b==1
    figure;
    plot([data,ma20,ma60]);
    legend('data','ma20','ma60','Location','Best');
    title('ma60回测','Fontweight','bold');
    hold on
    plot(pricet,'ro','markersize',4);
    plot(pricec,'ro','markersize',4);
    xxx=1:length(data);
    text(xxx,pricet,num2str(sgt),'FontSize',8);
    text(xxx,pricec,num2str(sgt),'FontSize',8);
    hold off
    % figure;
    % subplot(2,1,1);
    % plot(ttr5);
    % subplot(2,1,2);
    % plot(maxd5);
end
save alldata
end

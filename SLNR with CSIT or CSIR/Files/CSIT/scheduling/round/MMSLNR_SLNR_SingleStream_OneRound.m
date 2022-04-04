function [KK_new, u_new, SLNR_temp_new, eig_num_temp, over_new] = MMSLNR_SLNR_SingleStream_OneRound(N,K_all,K,Mi,H,sigma2,KK_old,u_old,SLNR_temp_old,over_old)

% Scheduling
KK_new=KK_old;
u_new=u_old;       % Single data stream
SLNR_temp_new=SLNR_temp_old;
eig_num_temp=0;
over_new=1;

channel_gain=zeros(1,K_all);
HHH=zeros(Mi,N);
for i1=1:K_all,
    HHH=H((i1-1)*Mi+1:i1*Mi,:);
    channel_gain(1,i1)=trace(HHH'*HHH);
end

[ch_gain,index]=another_sort(channel_gain);

if(over_old==0),
    if(max(SLNR_temp_old)==0),
        % the first round
        KK_new=index(1,1:K);
        H_now=zeros(K*Mi,N);
        for i1=1:K,
            H_now((i1-1)*Mi+1:i1*Mi,:)=H((KK_new(1,i1)-1)*Mi+1:KK_new(1,i1)*Mi,:);
        end
        
        for i1=1:K,
            Hi=zeros(Mi,N);
            Hk=zeros(Mi,N);
            
            Hi=H_now((i1-1)*Mi+1:i1*Mi,:);
            C=Hi'*Hi;
            
            D=Mi*sigma2*eye(N);
            for i2=1:K,
                if i2~=i1,
                    Hk=H_now((i2-1)*Mi+1:i2*Mi,:);
                    D=D+Hk'*Hk;
                end
            end
            
            [eig_vec, eig_val]=eig(C,D);
            temp1=zeros(1,N);
            for i2=1:N,
                temp1(1,i2)=eig_val(i2,i2);
            end
            [max_val,max_pos]=max(temp1);
            v=eig_vec(:,max_pos);
            u_new(:,i1)=v/(sqrt((v')*v));
            
            SLNR_temp_new(1,i1)=real(max_val);
        end
        
        eig_num_temp=eig_num_temp+K;
        over_new=0;
        
    else
        % the following rounds
        temp1=zeros(1,K);
        temp2=zeros(1,K);
        u_temp=zeros(N,K);
        
        [min_val, min_pos]=min(SLNR_temp_old);
        changed=0;
        for i1=1:K_all,
            scheduled=0;
            % check whether this user has been scheduled
            for i2=1:K,
                if index(1,i1)==KK_old(1,i2);
                    scheduled=1;
                    break;
                end
            end
            
            if scheduled==0,
                temp1=KK_old;      % KK_temp is used to store the scheduling result of last round
                temp1(1,min_pos)=index(1,i1);       % try to replace��ע��index�е�Ԫ�زŴ����������û����
                
                for i2=1:K,
                    H_now((i2-1)*Mi+1:i2*Mi,:)=H((temp1(1,i2)-1)*Mi+1:temp1(1,i2)*Mi,:);
                end
                
                Hi=zeros(Mi,N);
                Hk=zeros(Mi,N);
                for i2=1:K,
                    Hi=H_now((i2-1)*Mi+1:i2*Mi,:);
                    C=Hi'*Hi;
                    
                    D=Mi*sigma2*eye(N);
                    for i3=1:K,
                        if i3~=i2,
                            Hk=H_now((i3-1)*Mi+1:i3*Mi,:);
                            D=D+Hk'*Hk;
                        end
                    end
                    
                    [eig_vec, eig_val]=eig(C,D);
                    temp3=zeros(1,N);
                    for i3=1:N,
                        temp3(1,i3)=eig_val(i3,i3);
                    end
                    [max_val, max_pos]=max(temp3);
                    v=eig_vec(:,max_pos);
                    u_temp(:,i2)=v/(sqrt((v')*v));
                    
                    temp2(1,i2)=real(max_val);
                end
                
                eig_num_temp=eig_num_temp+K;
                
                if min(temp2)>min_val,
                    KK_new=temp1;
                    SLNR_temp_new=temp2;
                    u_new=u_temp;
                    over_new=0;
                    break;
                end
            end
        end
        
    end
    
end
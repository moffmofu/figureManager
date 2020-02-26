classdef ErspStorageManager<handle
    % ERSPクラスが計算をつかさどるのに対し、こちらはERSPデータの保存,引き出しをつかさどる
    % ERSPデータ自体の保持は外に出す。あくまで取り扱いのインタフェース
    properties
        projectName
        id
        roi
        task
        flags
        eegName
        erspName
        erspName_HARD
    end
    properties (Access=private)
        storageDir="../../3_data"
        eegStorageDir="E:/FUKUDA_MORI/3_DATA"
    end
    
    methods
        function [obj]=ErspStorageManager(projectName,id,roi,task)
            % parameter:
            %   analysisName : name of analysis pipeline (str)
            %   projectName : name of experiment protocol (str)
            %   id : individual id for subject(str)
            %   roi : region of interest(str)
            %   task : name of task(str)
            
            % setting for target
            obj.projectName=projectName;
            obj.id=id;
            obj.roi=roi;
            obj.task=task;
            
            % initialize flag
            obj.flags=struct();
            obj.flags.saturate=100;
            obj.flags.clean=false;
            obj.flags.score="percent";
            obj.flags.lap=false;
            obj.flags.reset=false;
            
            % initialize storage path
            obj.naming_eeg();
            obj.naming();
        end
        
        function [cERD,iERD,Eeg]=get(obj)
            % load ERSP data if it is exists.
            % in case it is not there, generate it.
            % 返すのはtrial*freq*block
            fprintf("search: "+obj.erspName+".mat\n")
            origin=cd(obj.storageDir+"/"+obj.projectName);
            if isfile(obj.erspName+".mat") && not(obj.flags.reset)
                fprintf("-> use existing ERD file.\n")
                load(obj.erspName)
                cERD=ERD.c;
                iERD=ERD.i;
                cd(origin);
            else
                cd(origin);
                fprintf("-> load Eeg file and generate new ERD file\n")
                load(obj.eegName);
                eeg=car;
                Target=squeeze(eeg(:,:));
                [cERD,iERD,Eeg]=obj.generate(Target);
            end
        end
        
        function [cERD,iERD,Eeg]=get_HARD(obj)
            % load ERSP data if it is exists.
            % in case it is not there, generate it.
            % 返すのはtrial*freq*block
            fprintf("search: "+obj.erspName_HARD+".mat\n")
            origin=cd(obj.storageDir+"/"+obj.projectName);
            if isfile(obj.erspName_HARD+".mat") && not(obj.flags.reset)
                fprintf("-> use existing ERD file.\n")
                load(obj.erspName_HARD)
                cERD=ERD.c;
                iERD=ERD.i;
                cd(origin);
            else
                cd(origin);
                fprintf("-> load Eeg file and generate new ERD file\n")
                load(obj.eegName);
                cERD=obj.generate_HARD(36);
                iERD=obj.generate_HARD(104);
                ERD=struct();
                ERD.c=cERD;
                ERD.i=iERD;
                Eeg=car;
                for i=1:size(Eeg,1)
                    for j=1:size(Eeg,2)
                        Eeg(i,j).data="erased";
                    end
                end
                name=obj.storageDir+"/"+obj.projectName+"/"+obj.erspName_HARD;
                save(name,"ERD","Eeg");
            end
            if obj.flags.saturate
                lim=obj.flags.saturate;
                cERD=min(max(cERD,-lim),lim);
                iERD=min(max(iERD,-lim),lim);
            end
        end
        
        function eegName=naming_eeg(obj)
            % これはおそらくeegStorageManagerクラスを作ってそこのstaticとしたほうがよい
            obj.eegName=obj.eegStorageDir+"/"+obj.projectName;
            obj.eegName=obj.eegName+"/"+obj.projectName+obj.id;
            obj.eegName=obj.eegName+"("+obj.roi+"_"+obj.task+",CAR).mat";
            eegName=obj.eegName;
        end
        
        function obj=changeTarget(obj,projectName,id,roi,task)
            obj.projectName=projectName;
            obj.id=id;
            obj.roi=roi;
            obj.task=task;
        end
        
        function name=naming(obj)
            % emit a name of file based on .flags property.
            % enable "keyword" for .setFlag() is given in here.
            name="ERD-"+obj.projectName+obj.id+"-"+obj.roi+"_"+obj.task;
            name_H=name;
            if obj.flags.saturate
                name=name+"(sat)";
            end
            if obj.flags.clean
                name=name+"(cleaned)";
            end
            name=name+"("+obj.flags.score+")";
            name_H=name_H+"("+obj.flags.score+")";
            if obj.flags.lap
                name=name+"(Lap)";
                name_H=name_H+"(Lap)";
            end
            obj.erspName=name;
            obj.erspName_HARD=name_H+"_HARD";
        end
        
        function setFlag(obj,varargin)
            % Even number of inputs consisted from keyword and boolean must be given.
            % keyword:
            %   clean   : ignore dirty trial annotated preliminaly.
            %   car     : common average reference
            %   score   : calculate ERSP as dB,percent,tVal.(default:percent)
            %   saturate: saturation. it is reccomended that give int like
            %             100 instead of boolean.
            %   (median): use median. default=false and use mean.
            %
            if rem(nargin-1,2)
                error("invalid parameter.")
            end
            for i=1:(nargin-1)/2
                obj.flags.(varargin{(i*2)-1})=varargin{i*2};
            end
            obj.naming_eeg();
            obj.naming();
        end
        
        function [cERD,iERD,Eeg]=generate(obj,Eeg)
            % 旧eeg2Ersp() 関数。単一ファイルであった。
            % Eegは単一実験としろ。したがってサイズは(block*trial)の二次元。
            % 返すのはtrial*freq*block
            % FOIからは独立した存在であれ
            % nasty output. It is needed to remove Eeg.
            trialSize=size(Eeg,2);
            blockSize=size(Eeg,1);
            maxF=35;
            iERD=zeros(trialSize,maxF,size(Eeg,1));  %ipsi電極周辺のERD
            cERD=zeros(trialSize,maxF,size(Eeg,1));  %cont電極周辺のERD
            for i = 1:trialSize
                for j=1:blockSize
                    ipsi=Ersp2;
                    cont=Ersp2;
                    
                    if obj.flags.clean
                        if not(Eeg(j,i).Flag)
                            % skip bad epoch
                            cERD(j,:,i)=NaN;
                            iERD(j,:,i)=NaN;
                            continue;
                        end
                    end
                    
                    ipsi.offlineInitialize;
                    ipsi.flag_Saturate=obj.flags.saturate;
                    cont.offlineInitialize;
                    cont.flag_Saturate=obj.flags.saturate;
                    if obj.flags.lap
                        cont.preSetCh("C3_LLap4");
                        ipsi.preSetCh("C4_LLap4");
                    else
                        cont.pCh=36;
                        ipsi.pCh=104;
                    end
                    
                    ipsi.startFreq=[];
                    ipsi.endFreq=[];
                    cont.startFreq=[];
                    cont.endFreq=[];
                    if strcmpi(obj.flags.score,"tVal")
                        ipsi.getRef_Log(Eeg(j,i).data.rest);
                        cont.getRef_Log(Eeg(j,i).data.rest);
                        ipsi.execute_tval(Eeg(j,i).data.task);
                        cont.execute_tval(Eeg(j,i).data.task);
                    elseif strcmpi(obj.flags.score,"dB")
                        ipsi.getRef(Eeg(j,i).data.rest);
                        cont.getRef(Eeg(j,i).data.rest);
                        ipsi.execute_dB(Eeg(j,i).data.task);
                        cont.execute_dB(Eeg(j,i).data.task);
                    else
                        ipsi.getRef(Eeg(j,i).data.rest);
                        cont.getRef(Eeg(j,i).data.rest);
                        ipsi.execute(Eeg(j,i).data.task);
                        cont.execute(Eeg(j,i).data.task);
                    end
                    iERD(i,:,j)=nanmean(ipsi.scores(1:maxF,:),2);
                    cERD(i,:,j)=nanmean(cont.scores(1:maxF,:),2);
                    % compress window-wise
                    
                    Eeg(j,i).data="erased";
                    % erase wave contained in Eeg to make size small.
                end
            end
            ERD=struct();
            ERD.c=cERD;
            ERD.i=iERD;
            name=obj.storageDir+"/"+obj.projectName+"/"+obj.erspName;
            save(name,"ERD","Eeg");
        end
        
        function ERD=generate_HARD(obj,channel)
            % without compressing window-wise.
            load(obj.eegName);
            eeg=car;
            trialSize=size(eeg,2);
            blockSize=size(eeg,1);
            maxF=35;
            winS=1000;
            stride=100;
            winN=round((length(eeg(1,1).data.task)-winS)/stride)+1;
            ERD=zeros(trialSize,maxF,size(eeg,1),winN);
            for i = 1:trialSize
                for j=1:blockSize
                    tango=Ersp2;
                    
                    if obj.flags.clean
                        if not(eeg(j,i).Flag)
                            % skip bad epoch
                            ERD(j,:,i)=NaN;
                            continue;
                        end
                    end
                    
                    tango.offlineInitialize;
                    tango.flag_Saturate=false;  % caution!!!!
                    if obj.flags.lap
                        tango.preSetCh(channel);
                    else
                        tango.pCh=channel;
                    end
                    
                    tango.startFreq=[];
                    tango.endFreq=[];
                    
                    if strcmpi(obj.flags.score,"tVal")
                        %ここのメソッド変更ポリシーがtfやtopoと食い違っているので注意。
                        tango.getRef_Log(eeg(j,i).data.rest);
                        tango.execute_tval(eeg(j,i).data.task);
                    elseif strcmpi(obj.flags.score,"dB")
                        tango.getRef(eeg(j,i).data.rest);
                        tango.execute_dB(eeg(j,i).data.task);
                    else
                        tango.getRef(eeg(j,i).data.rest);
                        tango.execute(eeg(j,i).data.task);
                    end
                    erd=shiftdim(tango.scores(1:maxF,:),-2);
                    erd=permute(erd,[1,3,2,4]);
                    ERD(i,:,j,:)=erd;
                    eeg(j,i).data="erased";
                    % erase wave contained in eeg to make size small.
                end
            end
        end
    end
end
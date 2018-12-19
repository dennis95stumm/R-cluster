getFeatureData <- function (MyData, NrOfRecords)
{
  
  #ToDo: error handeling nad parameter pasing
  ########################################Calculating mel frequency and features based on it
  #size of the featurre vector (ncol=13*4+13*4+4*13=156)
  MeanChannel <- matrix(nrow = NrOfRecords, ncol = 156)
  SumChannel <- matrix(nrow = NrOfRecords, ncol = 156)
  VarChannel <- matrix(nrow = NrOfRecords, ncol = 156)
  MinChannel <- matrix(nrow = NrOfRecords, ncol = 156)
  MaxChannel <- matrix(nrow = NrOfRecords, ncol = 156)
  SkewChannel <- matrix(nrow = NrOfRecords, ncol = 156)
  KurtChannel <- matrix(nrow = NrOfRecords, ncol = 156)
  EntropyChannel <- matrix(nrow = NrOfRecords, ncol = 156)
  LabelChannel <- matrix(nrow = NrOfRecords, ncol = 1)
  
  numRows <-length(MyData)
  
  foreach (i=1:NrOfRecords) %dopar% {
    ChannelsWavobj <- WaveMC(transpose(MyData[c(4*(i-1)+1,4*(i-1)+2,4*(i-1)+3, 4*(i-1)+4 ),-numRows]), samp.rate = 5512, bit = 16)
    
    #calculating Mel frequency of 4 channels
    
    Channel1Mel <- melfcc(ChannelsWavobj[,1], sr = 5512, numcep = 13)
    Channel2Mel <- melfcc(ChannelsWavobj[,2], sr = 5512, numcep = 13)
    Channel3Mel <- melfcc(ChannelsWavobj[,3], sr = 5512, numcep = 13)
    Channel4Mel <- melfcc(ChannelsWavobj[,4], sr = 5512, numcep = 13)
    
    #calculating delta queficients of the Mel frequencies of 4 channels
    ChannelMelTemp <- Channel1Mel
    dimMel <- dim(Channel1Mel)
    ChannelMelTemp[1,] <- -Channel1Mel[1,]
    ChannelMelTemp[2:dimMel[1],] <- -Channel1Mel[1:dimMel[1]-1,]
    Channel1DeltaMel <- (Channel1Mel + ChannelMelTemp)
    
    ChannelMelTemp <- Channel2Mel
    ChannelMelTemp[1,] <- -Channel2Mel[1,]
    ChannelMelTemp[2:dimMel[1],] <- -Channel2Mel[1:dimMel[1]-1,]
    Channel2DeltaMel <- Channel2Mel + ChannelMelTemp
    
    ChannelMelTemp <- Channel3Mel
    ChannelMelTemp[1,] <- -Channel3Mel[1,]
    ChannelMelTemp[2:dimMel[1],] <- -Channel3Mel[1:dimMel[1]-1,]
    Channel3DeltaMel <- Channel3Mel + ChannelMelTemp
    
    
    ChannelMelTemp <- Channel4Mel
    ChannelMelTemp[1,] <- -Channel4Mel[1,]
    ChannelMelTemp[2:dimMel[1],] <- -Channel4Mel[1:dimMel[1]-1,]
    Channel4DeltaMel <- Channel4Mel + ChannelMelTemp
    
    #calculating deltaDelta queficients of the Mel frequencies of 4 channels
    ChannelMelTemp <- Channel1DeltaMel
    ChannelMelTemp[1,] <- -Channel1DeltaMel[1,]
    ChannelMelTemp[2:dimMel[1],] <- -Channel1DeltaMel[1:dimMel[1]-1,]
    Channel1deltaDeltaMel <- (Channel1DeltaMel + ChannelMelTemp)
    
    ChannelMelTemp <- Channel2DeltaMel
    ChannelMelTemp[1,] <- -Channel2DeltaMel[1,]
    ChannelMelTemp[2:dimMel[1],] <- -Channel2DeltaMel[1:dimMel[1]-1,]
    Channel2deltaDeltaMel <- (Channel2DeltaMel + ChannelMelTemp)
    
    ChannelMelTemp <- Channel3DeltaMel
    ChannelMelTemp[1,] <- -Channel3DeltaMel[1,]
    ChannelMelTemp[2:dimMel[1],] <- -Channel3DeltaMel[1:dimMel[1]-1,]
    Channel3deltaDeltaMel <- (Channel3DeltaMel + ChannelMelTemp)
    
    ChannelMelTemp <- Channel4DeltaMel
    ChannelMelTemp[1,] <- -Channel4DeltaMel[1,]
    ChannelMelTemp[2:dimMel[1],] <- -Channel4DeltaMel[1:dimMel[1]-1,]
    Channel4deltaDeltaMel <- (Channel4DeltaMel + ChannelMelTemp)
    
    
    #calculating the statistical features
    MeanChannel[i,] <- as.matrix(apply(cbind(Channel1Mel, Channel2Mel, Channel3Mel, Channel4Mel, Channel1DeltaMel, Channel2DeltaMel, Channel3DeltaMel, Channel4DeltaMel, Channel1deltaDeltaMel, Channel2deltaDeltaMel, Channel3deltaDeltaMel, Channel4deltaDeltaMel), 2 , FUN = mean))
    SumChannel[i,] <- as.matrix(apply(abs(cbind(Channel1Mel, Channel2Mel, Channel3Mel, Channel4Mel, Channel1DeltaMel, Channel2DeltaMel, Channel3DeltaMel, Channel4DeltaMel,Channel1deltaDeltaMel, Channel2deltaDeltaMel, Channel3deltaDeltaMel, Channel4deltaDeltaMel)), 2 , FUN = sum))
    VarChannel[i,] <- as.matrix(apply(cbind(Channel1Mel, Channel2Mel, Channel3Mel, Channel4Mel, Channel1DeltaMel, Channel2DeltaMel, Channel3DeltaMel, Channel4DeltaMel,Channel1deltaDeltaMel, Channel2deltaDeltaMel, Channel3deltaDeltaMel, Channel4deltaDeltaMel), 2 , FUN = var))
    MinChannel[i,] <- as.matrix(apply(cbind(Channel1Mel, Channel2Mel, Channel3Mel, Channel4Mel, Channel1DeltaMel, Channel2DeltaMel, Channel3DeltaMel, Channel4DeltaMel,Channel1deltaDeltaMel, Channel2deltaDeltaMel, Channel3deltaDeltaMel, Channel4deltaDeltaMel), 2 , FUN = min))
    MaxChannel[i,] <- as.matrix(apply(cbind(Channel1Mel, Channel2Mel, Channel3Mel, Channel4Mel, Channel1DeltaMel, Channel2DeltaMel, Channel3DeltaMel, Channel4DeltaMel,Channel1deltaDeltaMel, Channel2deltaDeltaMel, Channel3deltaDeltaMel, Channel4deltaDeltaMel), 2 , FUN = max))
    SkewChannel[i,] <- as.matrix(apply(cbind(Channel1Mel, Channel2Mel, Channel3Mel, Channel4Mel, Channel1DeltaMel, Channel2DeltaMel, Channel3DeltaMel, Channel4DeltaMel,Channel1deltaDeltaMel, Channel2deltaDeltaMel, Channel3deltaDeltaMel, Channel4deltaDeltaMel), 2 , FUN = skewness))
    KurtChannel[i,] <- as.matrix(apply(cbind(Channel1Mel, Channel2Mel, Channel3Mel, Channel4Mel, Channel1DeltaMel, Channel2DeltaMel, Channel3DeltaMel, Channel4DeltaMel,Channel1deltaDeltaMel, Channel2deltaDeltaMel, Channel3deltaDeltaMel, Channel4deltaDeltaMel), 2 , FUN = kurtosis))
    EntropyChannel[i,] <- as.matrix(apply(cbind(Channel1Mel, Channel2Mel, Channel3Mel, Channel4Mel, Channel1DeltaMel, Channel2DeltaMel, Channel3DeltaMel, Channel4DeltaMel,Channel1deltaDeltaMel, Channel2deltaDeltaMel, Channel3deltaDeltaMel, Channel4deltaDeltaMel), 2 , FUN = entropy))
    
    LabelChannel[i,1] <- as.matrix(MyData[4*(i-1)+1, numRows]+1)
  }
  
  FeatureVector <- cbind(MeanChannel,SumChannel,VarChannel,MinChannel, MaxChannel, SkewChannel, KurtChannel, EntropyChannel, LabelChannel)
  
  return(FeatureVector)
}
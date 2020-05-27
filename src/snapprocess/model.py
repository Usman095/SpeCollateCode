import torch.nn as nn
import torch.nn.functional as F

from src.snapconfig import config


class Net(nn.Module):
    def __init__(self, vocab_size, output_size=512, embedding_dim=512, hidden_lstm_dim=1024, lstm_layers=2):
        super(Net, self).__init__()

        self.spec_size = config.get_config(section='input', key='spec_size')
        self.output_size = output_size
        self.lstm_layers = lstm_layers
        self.hidden_lstm_dim = hidden_lstm_dim
        self.embedding_dim = embedding_dim
        
        self.embedding = nn.Embedding(vocab_size, embedding_dim)
        self.lstm = nn.LSTM(embedding_dim, self.hidden_lstm_dim, self.lstm_layers,
                            # dropout=0.5, 
                            batch_first=True, bidirectional=True)
        # self.lstm = nn.DataParallel(self.lstm)
        
        self.linear1_1 = nn.Linear(self.spec_size, 1024)
        self.linear1_2 = nn.Linear(1024, 512)
        
        self.linear2_1 = nn.Linear(2048, 1024)
        self.linear2_2 = nn.Linear(1024, 512)
        
        self.dropout2 = nn.Dropout(0.3)
        #self.dropout3 = nn.Dropout(0.3)
        
    def forward(self, data, hidden):
        specs = data[0]
        peps = data[1]
        # print(peps.type())
        # print('Input to the model size: {}'.format(specs.size()))
        # print('Input to the model size: {}'.format(peps.size()))
        # peps = peps.unsqueeze(-1).float()
        # print(peps.type())
        
        embeds = self.embedding(peps)
        lstm_out, hidden = self.lstm(embeds, hidden)
        # print(lstm_out.size())
        lstm_out = lstm_out[:, -1, :]
        # print(lstm_out.size())
        #lstm_out = torch.mean(lstm_out, dim=1)
        lstm_out = lstm_out.contiguous().view(-1, self.hidden_lstm_dim * 2)
        out = self.dropout2(lstm_out)
        
        out = self.linear2_1(out)
        out = F.relu(out)
        out = self.dropout2(out)
        
        out = self.linear2_2(out)
        out = F.relu(out)
        
        # out = out.view(batch_size, peps.size()[1], 512)
        # out = out[:,-1,:]
        out_pep = F.normalize(out)
        
        out = self.linear1_1(specs.view(-1, self.spec_size))
        out = F.relu(out)
        out = self.dropout2(out)
        out = self.linear1_2(out)
        out = F.relu(out)
        out_spec = F.normalize(out)
        
        res = out_spec, out_pep, hidden
        return res
    
    def init_hidden(self, batch_size):
        weight = next(self.parameters()).data
        hidden = (weight.new(self.lstm_layers * 2, batch_size, self.hidden_lstm_dim).zero_(),
                      weight.new(self.lstm_layers * 2, batch_size, self.hidden_lstm_dim).zero_())
        return hidden
    
    def name(self):
        return "Net"
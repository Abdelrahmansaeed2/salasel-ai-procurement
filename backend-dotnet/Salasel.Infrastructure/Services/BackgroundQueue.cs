using System.Threading.Channels;

namespace Salasel.Infrastructure.Services;

public interface IBackgroundQueue
{
    ValueTask EnqueueAsync(VoiceProcessingJob job);
    IAsyncEnumerable<VoiceProcessingJob> DequeueAllAsync(CancellationToken ct);
}

public record VoiceProcessingJob(int VoiceLogId, int MerchantId, string FilePath);

public class BackgroundQueue : IBackgroundQueue
{
    private readonly Channel<VoiceProcessingJob> _channel =
        Channel.CreateUnbounded<VoiceProcessingJob>(new UnboundedChannelOptions
        {
            SingleReader = true,
            SingleWriter = false
        });

    public ValueTask EnqueueAsync(VoiceProcessingJob job) =>
        _channel.Writer.WriteAsync(job);

    public IAsyncEnumerable<VoiceProcessingJob> DequeueAllAsync(CancellationToken ct) =>
        _channel.Reader.ReadAllAsync(ct);
}

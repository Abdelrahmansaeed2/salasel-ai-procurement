using System.Threading.Channels;

namespace Salasel.Infrastructure.Services;

// Mirrors IBackgroundQueue/BackgroundQueue for voice processing — kept as a
// separate channel rather than genericizing the existing one, so the voice
// pipeline isn't touched by this addition.
public interface IKnowledgeIndexingQueue
{
    ValueTask EnqueueAsync(KnowledgeIndexingJob job);
    IAsyncEnumerable<KnowledgeIndexingJob> DequeueAllAsync(CancellationToken ct);
}

public record KnowledgeIndexingJob(int DocumentId);

public class KnowledgeIndexingQueue : IKnowledgeIndexingQueue
{
    private readonly Channel<KnowledgeIndexingJob> _channel =
        Channel.CreateUnbounded<KnowledgeIndexingJob>(new UnboundedChannelOptions
        {
            SingleReader = true,
            SingleWriter = false
        });

    public ValueTask EnqueueAsync(KnowledgeIndexingJob job) =>
        _channel.Writer.WriteAsync(job);

    public IAsyncEnumerable<KnowledgeIndexingJob> DequeueAllAsync(CancellationToken ct) =>
        _channel.Reader.ReadAllAsync(ct);
}